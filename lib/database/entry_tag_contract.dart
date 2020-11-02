import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class EntryTagContract {
  static const entry_tag_table = 'entries_tags';

  static const entryIdColumn = EntryContract.idColumn;
  static const tagIdColumn = TagContract.tagIdColumn;

  ///Inserts or update the tags of an entry
  static Future<int> save(int entryId, int tagId) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    map[entryIdColumn] = entryId;
    map[tagIdColumn] = tagId;

    int idTagEntryInserted = await db.insert(entry_tag_table, map,
        conflictAlgorithm: ConflictAlgorithm.ignore);

    //On fail of insert due to repeated entry
    if (idTagEntryInserted == null) {
      List<Map<String, dynamic>> map = await db.query(entry_tag_table,
          columns: ['rowid', entryIdColumn, tagIdColumn],
          where: '$entryIdColumn = ? AND $tagIdColumn = ?',
          whereArgs: [entryId, tagId]);

      if (map.length > 1) {
        throw Exception('Duplicate entry in table: $entry_tag_table');
      }

      idTagEntryInserted = map[0]['rowid'] as int;
    }

    if (idTagEntryInserted == null || idTagEntryInserted <= 0) {
      throw Exception('Invalid EntryXTagID!');
    }

    return idTagEntryInserted;
  }

  //static Future<List<TagModel>> query(String query) async {}
}
