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
  static Future<void> save(EntryModel entry, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }
    var map = entry.toMap();

    int idEntryInserted;
    if (!entry.isRecorded()) {
      //New Entry
      idEntryInserted = await db.insert(entry_table, map);
    } else {
      //Update the entry
      int rowsUpdated = await db.update(entry_table, map,
          where: '$idColumn = ?', whereArgs: [entry.entryId]);
      if (rowsUpdated == null || rowsUpdated != 1) {
        throw 'Error on updating entry!Missing or invalid ID updated!';
      }
      idEntryInserted = entry.entryId;
    }

    if (idEntryInserted == null || idEntryInserted <= 0) {
      throw Exception('Invalid ID of new Entry!: $idEntryInserted');
    }

    List<TagModel> tagsList = entry.tags;
    List<int> tagIdsInserted = [];
    if (tagsList != null && tagsList.isNotEmpty) {
      tagIdsInserted =
          await Future.wait(tagsList.map((tag) => TagContract.save(tag, db)));
    }

    //sanity check
    if (entry.tags.length != tagIdsInserted.length) {
      String debugInfo = 'missing tagIDs on entry insert!';
      throw Exception(debugInfo);
    }

    //saves on entryXtags table
    await EntryTagContract.save(idEntryInserted, tagIdsInserted, db);
  }

  ///Return a list of [EntryModel] in the range of [start] and [end].
  static Future<List<EntryModel>> queryByDate(DateTime start, DateTime end,
      [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

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
      entry.tags = await TagContract.queryByEntryId(entry.entryId, db);
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
