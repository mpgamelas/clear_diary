import 'package:clear_diary/database/database_instance.dart';
import 'package:clear_diary/database/entry_tag_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

class EntryContract {
  static const entry_table = 'entries';

  static const idColumn = 'entry_id';
  static const dateCreatedColumn = 'date_created';
  static const dateModifedColumn = 'date_modified';
  static const dateAssignedColumn = 'date_assigned';
  static const titleColumn = 'title';
  static const bodyColumn = 'body';

  ///Inserts or update an Entry
  ///todo: can be refactored here.
  static void save(EntryModel entry) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    bool isInsert = entry.entryId == null || entry.entryId <= 0;
    if (isInsert) {
      map[dateCreatedColumn] = entry.dateCreated.millisecondsSinceEpoch;
      map[dateModifedColumn] = entry.dateModified.millisecondsSinceEpoch;
      map[dateAssignedColumn] = entry.dateAssigned.millisecondsSinceEpoch;

      map[titleColumn] = entry.title;
      map[bodyColumn] = entry.body;

      int idEntryInserted = await db.insert(entry_table, map);

      if (idEntryInserted == null || idEntryInserted <= 0) {
        throw Exception('Invalid ID of new Entry!: $idEntryInserted');
      }

      List<TagModel> tagList = entry.tags;
      List<int> tagIdsInserted = [];
      if (tagList != null && tagList.isNotEmpty) {
        for (TagModel tag in tagList) {
          int tagIdInserted = await TagContract.save(tag);

          if (tagIdInserted == null || tagIdInserted <= 0) {
            throw Exception('Invalid TagID!');
          }
          tagIdsInserted.add(tagIdInserted);
        }
      }

      //sanity check
      if (tagList.length != tagIdsInserted.length) {
        String debugInfo = 'missing tagIDs on entry insert!';
        throw Exception(debugInfo);
      }

      //saves on entryXtags table
      for (int tagId in tagIdsInserted) {
        await EntryTagContract.save(idEntryInserted, tagId);
      }
    } else {
      //Update the entry table
      map[idColumn] = entry.entryId;
      map[dateCreatedColumn] = entry.dateCreated.millisecondsSinceEpoch;
      map[dateModifedColumn] = DateTime.now().millisecondsSinceEpoch;
      map[dateAssignedColumn] = entry.dateAssigned.millisecondsSinceEpoch;
      map[titleColumn] = entry.title;
      map[bodyColumn] = entry.body;
      int rowsUpdated = await db.update(entry_table, map,
          where: '$idColumn = ?', whereArgs: [entry.entryId]);
      if (rowsUpdated == null || rowsUpdated <= 0) {
        throw 'Error on updating entry!';
      }

      //Updates each tag on the new entry, adding them on the tags table if it
      //doesn't exists.
      List<TagModel> tagList = entry.tags;
      List<int> tagIdsUpdated = [];
      if (tagList != null && tagList.isNotEmpty) {
        for (TagModel tag in tagList) {
          int tagIdInserted = await TagContract.save(tag);

          if (tagIdInserted == null || tagIdInserted <= 0) {
            throw Exception('Invalid TagID!');
          }
          tagIdsUpdated.add(tagIdInserted);
        }
      }

      //sanity check
      if (tagList.length != tagIdsUpdated.length) {
        String debugInfo = 'missing tagIDs on entry update!';
        throw debugInfo;
      }

      //Updates the entryXTags table
      for (int tagId in tagIdsUpdated) {
        await EntryTagContract.save(entry.entryId, tagId);
      }
    }
  }

  ///Return a list of [EntryModel] in the range of [start] and [end].
  static Future<List<EntryModel>> queryByDate(
      DateTime start, DateTime end) async {
    Database db = await DatabaseInstance.instance.database;

    int startDate = start.millisecondsSinceEpoch;
    int endDate = end.millisecondsSinceEpoch;

    List<Map<String, dynamic>> queryList = await db.query(entry_table,
        columns: [
          idColumn,
          dateCreatedColumn,
          dateModifedColumn,
          dateAssignedColumn,
          titleColumn,
          bodyColumn
        ],
        where: '$dateAssignedColumn BETWEEN ? AND ?',
        orderBy: '$dateAssignedColumn DESC',
        whereArgs: [startDate, endDate]);

    List<EntryModel> listEntries = [];
    for (Map<String, dynamic> map in queryList) {
      EntryModel entry = EntryModel.fromMap(map);
      listEntries.add(entry);
    }

    for (var entry in listEntries) {
      entry.tags = await TagContract.queryByEntryId(entry.entryId);
    }

    return listEntries;
  }

  ///For testing purposes.
  static List<EntryModel> getMockEntries() {
    List<EntryModel> listEntries = [];
    for (int i = 1; i <= 30; i++) {
      EntryModel entry = EntryModel();
      entry.entryId = i;
      entry.dateCreated = DateTime.now();
      entry.dateModified = DateTime.now();
      entry.dateAssigned = DateTime.now();
      entry.title = 'DEBUG TITLE $i';
      entry.body = 'DEBUG BODY $i';
      entry.tags = [TagModel('tag$i'), TagModel('test'), TagModel('testet')];
      listEntries.add(entry);
    }

    return listEntries;
  }

  //
  // Future<int> queryRowCount() async {
  //   Database db = await instance.database;
  //   return Sqflite.firstIntValue(
  //       await db.rawQuery('SELECT COUNT(*) FROM $entry_table'));
  // }
  //
  // Future<int> update(Map<String, dynamic> row) async {
  //   Database db = await instance.database;
  //   int id = row[idColumn];
  //   return await db
  //       .update(entry_table, row, where: '$idColumn = ?', whereArgs: [id]);
  // }
  //
  // Future<int> delete(int id) async {
  //   Database db = await instance.database;
  //   return await db.delete(entry_table, where: '$idColumn = ?', whereArgs: [id]);
  // }
}
