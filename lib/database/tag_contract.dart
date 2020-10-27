import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class TagContract {
  static const tags_table = 'tags';
  static const tagId = 'tag_id';
  static const tagDateCreated = 'date_created';
  static const tagDateModified = 'date_modified';
  static const tag = 'tag';

  ///Inserts or update a Tag, returns the rowID of the tag saved.
  static Future<int> save(TagModel tagModel) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    bool isInsert = tagModel.tagId == null || tagModel.tagId <= 0;
    if (isInsert) {
      int secondsUnix = secondsSinceEpoch(DateTime.now());
      map[tagDateCreated] = secondsUnix;
      map[tagDateModified] = secondsUnix;

      map[tag] = tagModel.tag;

      int idEntryInserted = await db.insert(tags_table, map,
          conflictAlgorithm: ConflictAlgorithm.ignore);

      if (idEntryInserted == null) {
        List<Map<String, dynamic>> map = await db.query(tags_table,
            columns: [tagId, tag],
            where: '$tag LIKE ?',
            whereArgs: [tagModel.tag]);

        if (map.length > 1) {
          throw Exception('Duplicate tag in table: $tags_table');
        }

        idEntryInserted = map[0][tagId] as int;
      }
      return idEntryInserted;
    } else {
      //todo: update not implemented yet
      return -1;
    }
  }

  static Future<List<TagModel>> query(String query) async {
    if (query.length < 3) {
      return []; //don't even bother searching for 2 characters or less
    }

    Database db = await DatabaseInstance.instance.database;

    //todo: pending test
    var list = await db.query(tags_table,
        columns: [tag], where: '$tag LIKE ?', whereArgs: [query]);

    var list2 = await db.rawQuery('''
    SELECT * FROM $tags_table WHERE $tag LIKE ?
    ''', [query]);

    return [];
  }

  static int secondsSinceEpoch(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}
