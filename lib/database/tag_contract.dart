import 'package:clear_diary/database/entry_tag_contract.dart';
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
  ///todo: can be refactored here.
  static Future<int> save(TagModel tagModel) async {
    Database db = await DatabaseInstance.instance.database;
    var map = <String, dynamic>{};

    bool isInsert = tagModel.tagId == null || tagModel.tagId <= 0;
    if (isInsert) {
      int milisegEpoch = DateTime.now().millisecondsSinceEpoch;
      map[tagDateCreatedColumn] = milisegEpoch;
      map[tagDateModifiedColumn] = milisegEpoch;

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
      map[tagIdColumn] = tagModel.tagId;
      map[tagDateCreatedColumn] = tagModel.dateCreated.millisecondsSinceEpoch;
      map[tagDateModifiedColumn] = DateTime.now().millisecondsSinceEpoch;
      map[tagColumn] = tagModel.tag;

      int rowsUpdated = await db.update(tags_table, map,
          where: '$tagIdColumn = ?', whereArgs: [tagModel.tagId]);

      if (rowsUpdated == null || rowsUpdated <= 0) {
        throw 'Error on updating entry!';
      }

      return tagModel.tagId;
    }
  }

  ///Searches tags that match a certain [String].
  static Future<List<TagModel>> queryByName(String query) async {
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

    List<TagModel> tagList = [];
    list.forEach((map) {
      tagList.add(TagModel.fromMap(map));
    });

    return tagList;
  }

  ///Searches the tags that belong to a single [EntryModel] ID.
  static Future<List<TagModel>> queryByEntryId(int entryId) async {
    Database db = await DatabaseInstance.instance.database;

    String querySql = '''
    SELECT * FROM $tags_table WHERE $tagIdColumn IN (
                                                  SELECT
                                                    ${EntryTagContract.tagIdColumn}
                                                  FROM
                                                    ${EntryTagContract.entry_tag_table}
                                                  WHERE
                                                    ${EntryTagContract.entryIdColumn} = ?
                                                )
    ''';
    var tagsQuery = await db.rawQuery(querySql, [entryId]);

    List<TagModel> tagsList = [];
    tagsQuery.forEach((tagQueryMap) {
      TagModel tag = TagModel.fromMap(tagQueryMap);
      tagsList.add(tag);
    });

    return tagsList;
  }
}
