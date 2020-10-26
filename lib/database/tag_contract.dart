import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class TagContract {
  static const tags_table = 'tags';
  static const tagId = 'tag_id';
  static const tagDateCreated = 'date_created';
  static const tagDateModified = 'date_modified';
  static const tag = 'tag';

  ///Inserts or update a Tag.
  static void save(TagModel tagModel) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    bool isInsert = tagModel.tagId == null || tagModel.tagId <= 0;
    if (isInsert) {
      map[tagDateCreated] = secondsSinceEpoch(tagModel.dateCreated);
      map[tagDateModified] = secondsSinceEpoch(tagModel.dateModified);

      map[tag] = tagModel.tag;

      int idEntryInserted = await db.insert(tags_table, map,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    } else {
      //todo:finish here
    }
  }

  static int secondsSinceEpoch(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}
