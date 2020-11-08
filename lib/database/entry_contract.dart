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
  ///todo: TAGS CAN BE DELETED FROM HERE CHECK
  static Future<void> save(EntryModel entry) async {
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

      List<TagModel> tagsList = entry.tags;
      List<int> tagIdsInserted = [];
      if (tagsList != null && tagsList.isNotEmpty) {
        tagIdsInserted =
            await Future.wait(tagsList.map((tag) => TagContract.save(tag)));
      }

      //sanity check
      if (entry.tags.length != tagIdsInserted.length) {
        String debugInfo = 'missing tagIDs on entry insert!';
        throw Exception(debugInfo);
      }

      //saves on entryXtags table
      await Future.wait(tagIdsInserted
          .map((idTag) => EntryTagContract.save(idEntryInserted, idTag)));
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
        tagIdsUpdated =
            await Future.wait(tagList.map((tag) => TagContract.save(tag)));
      }

      //sanity check
      if (tagList.length != tagIdsUpdated.length) {
        String debugInfo = 'missing tagIDs on entry update!';
        throw debugInfo;
      }

      //Updates the entryXTags table
      await Future.wait(tagIdsUpdated
          .map((idTag) => EntryTagContract.save(entry.entryId, idTag)));
    }
  }

  ///Return a list of [EntryModel] in the range of [start] and [end].
  static Future<List<EntryModel>> queryByDate(
      DateTime start, DateTime end) async {
    Database db = await DatabaseInstance.instance.database;

    int startDate = start.millisecondsSinceEpoch;
    int endDate = end.millisecondsSinceEpoch;

    List<Map<String, dynamic>> readOnlyList = await db.query(entry_table,
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

    List<Map<String, dynamic>> queryList = [];
    readOnlyList.forEach((element) {
      Map<String, dynamic> map = Map<String, dynamic>.from(element);
      queryList.add(map);
    });

    //todo: check if this code can be done in a single batch.
    List<EntryModel> listEntries = [];
    for (Map<String, dynamic> map in queryList) {
      EntryModel entry = EntryModel.fromMap(map);
      entry.tags = await TagContract.queryByEntryId(entry.entryId);
      listEntries.add(entry);
    }

    return listEntries;
  }

  ///Return a list of [EntryModel] which contains one or more of the tags in [tagList].
  static Future<List<EntryModel>> queryByTags(List<TagModel> tagList) async {
    Database db = await DatabaseInstance.instance.database;

    StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write('(');
    for (int i = 0; i < (tagList.length - 1); i++) {
      stringBuffer.write('${tagList[i].tagId},');
    }
    stringBuffer.write('${tagList.last.tagId})');

    String querySql = '''
    SELECT * FROM $entry_table WHERE $idColumn IN (
                                                  SELECT DISTINCT 
                                                    ${EntryTagContract.entryIdColumn}
                                                  FROM
                                                    ${EntryTagContract.entry_tag_table}
                                                  WHERE
                                                    ${EntryTagContract.tagIdColumn} IN ${stringBuffer.toString()}
                                                ) ORDER BY $dateAssignedColumn DESC
    ''';

    var readOnlyList = await db.rawQuery(querySql);

    List<EntryModel> entriesRetrieved = [];
    readOnlyList.forEach((element) {
      Map<String, dynamic> map = Map<String, dynamic>.from(element);
      EntryModel newEntry = EntryModel.fromMap(map);
      entriesRetrieved.add(newEntry);
    });

    for (EntryModel entry in entriesRetrieved) {
      entry.tags = await TagContract.queryByEntryId(entry.entryId);
    }

    return entriesRetrieved;
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
  //
  // Future<int> delete(int id) async {
  //   Database db = await instance.database;
  //   return await db.delete(entry_table, where: '$idColumn = ?', whereArgs: [id]);
  // }
}
