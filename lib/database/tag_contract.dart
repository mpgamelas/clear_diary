import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class TagContract {
  static const tags_table = 'tags';
  static const tagIdColumn = 'tag_id';
  static const tagDateCreatedColumn = 'date_created';
  static const tagDateModifiedColumn = 'date_modified';
  static const tagColumn = 'tag';

  ///Inserts or update a Tag, returns the rowID of the tag saved.
  static Future<int> save(TagModel tagModel) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    bool isInsert = tagModel.tagId == null || tagModel.tagId <= 0;
    if (isInsert) {
      int secondsUnix = DatabaseInstance.secondsSinceEpoch(DateTime.now());
      map[tagDateCreatedColumn] = secondsUnix;
      map[tagDateModifiedColumn] = secondsUnix;

      map[tagColumn] = tagModel.tag;

      int idTagInserted = await db.insert(tags_table, map,
          conflictAlgorithm: ConflictAlgorithm.ignore);

      if (idTagInserted == null) {
        List<Map<String, dynamic>> map = await db.query(tags_table,
            columns: [tagIdColumn, tagColumn],
            where: '$tagColumn LIKE ?',
            whereArgs: [tagModel.tag]);

        if (map.length > 1) {
          throw Exception('Duplicate tag in table: $tags_table');
        }

        idTagInserted = map[0][tagIdColumn] as int;
      }

      if (idTagInserted == null || idTagInserted <= 0) {
        throw Exception('Invalid TagID!');
      }

      return idTagInserted;
    } else {
      //todo: update not implemented yet
      if (tagModel.tagId != null && tagModel.tagId > 0) {
        return tagModel.tagId;
      } else {
        return -1;
      }
    }
  }

  static Future<List<TagModel>> query(String query) async {
    Database db = await DatabaseInstance.instance.database;

    var list = await db.query(tags_table,
        columns: [
          tagIdColumn,
          tagColumn,
          tagDateCreatedColumn,
          tagDateModifiedColumn
        ],
        where: '$tagColumn LIKE ?',
        whereArgs: ['%$query%']);

    //todo: fix the date conversion from int to DAteTime
    List<TagModel> tagList = [];
    list.forEach((map) {
      TagModel tag = TagModel(map[tagColumn]);
      tag.tagId = map[tagIdColumn];
      // tag.dateCreated = map[tagDateCreatedColumn];
      // tag.dateModified = map[tagDateModifiedColumn];

      tagList.add(tag);
    });

    return tagList;
  }
}
