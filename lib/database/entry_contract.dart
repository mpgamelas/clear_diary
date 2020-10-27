import 'package:clear_diary/database/database_instance.dart';
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
  static void save(EntryModel entry) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    //todo: branch for insert or update
    bool isInsert = entry.entryId == null || entry.entryId <= 0;
    if (isInsert) {
      map[dateCreatedColumn] = secondsSinceEpoch(entry.dateCreated);
      map[dateModifedColumn] = secondsSinceEpoch(entry.dateModified);
      map[dateAssignedColumn] = secondsSinceEpoch(entry.dateAssigned);

      map[titleColumn] = entry.title;
      map[bodyColumn] = entry.body;

      //todo: try catch here
      int idEntryInserted = await db.insert(entry_table, map);

      List<TagModel> tagList = entry.tags;
      if (tagList != null && tagList.isNotEmpty) {
        //todo: insert tags here and record on entryXtags table
        for (TagModel tag in tagList) {
          int tagIdInserted = await TagContract.save(tag);
        }
      }
    } else {
      map[idColumn] = entry.entryId;
      //todo:finish update here
    }
  }

  // Future<List<Map<String, dynamic>>> queryAllRows() async {
  //   Database db = await instance.database;
  //   return await db.query(entry_table);
  // }
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

  static int secondsSinceEpoch(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}
