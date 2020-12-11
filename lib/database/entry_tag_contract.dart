import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class EntryTagContract {
  static const entry_tag_table = 'entries_tags';

  static const entryIdColumn = EntryContract.idColumn;
  static const tagIdColumn = TagContract.tagIdColumn;

  ///Inserts or update the tags of an entry.
  ///May also erase entries if the tag was removed.
  static Future<void> save(int entryId, List<int> tagsId, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    await deleteByEntry(entryId, db); //delete all previous entries

    //Creates list of maps to be inserted.
    List<Map<String, dynamic>> entriesMapsList = [];
    for (int tagId in tagsId) {
      var map = <String, dynamic>{};
      map[entryIdColumn] = entryId;
      map[tagIdColumn] = tagId;
      entriesMapsList.add(map);
    }

    //Todo: do this in single transaction
    List<int> entryTagsIdInserted = [];
    for (var map in entriesMapsList) {
      int idTagEntryInserted = await db.insert(entry_tag_table, map,
          conflictAlgorithm: ConflictAlgorithm.ignore);
      entryTagsIdInserted.add(idTagEntryInserted);
    }

    if (entryTagsIdInserted.length != tagsId.length) {
      throw Exception('Error on saving in EntryXTags table!');
    }
  }

  ///Deletes all EntryXTags where the entryID matches and return the number of rows deleted.
  static Future<int> deleteByEntry(int entryId, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }
    return await db.delete(EntryTagContract.entry_tag_table,
        where: '$entryIdColumn = ?', whereArgs: [entryId]);
  }
}
