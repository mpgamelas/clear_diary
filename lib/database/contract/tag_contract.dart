import 'package:clear_diary/database/contract/entry_tag_contract.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import '../database_instance.dart';


class TagContract {
  static const tags_table = 'tags';
  static const tagIdColumn = 'tag_id';
  static const tagDateCreatedColumn = 'date_created';
  static const tagDateModifiedColumn = 'date_modified';
  static const tagColumn = 'tag';

  ///Inserts or update a Tag, returns the rowID of the tag saved.
  static Future<int> save(TagModel tagModel, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    var tagMap = tagModel.toMap();
    int idTagUpserted;
    if (!tagModel.isRecorded()) {
      //On tag insert
      //todo: replace by try catch
      idTagUpserted = await db.insert(tags_table, tagMap,
          conflictAlgorithm: ConflictAlgorithm.ignore);

      //If the same tag tries to be inserted.
      if (idTagUpserted == null || idTagUpserted <= 0) {
        List<Map<String, dynamic>> queryMap = await db.query(tags_table,
            columns: [tagIdColumn, tagColumn],
            where: '$tagColumn LIKE ?',
            whereArgs: [tagModel.tag]);
        if (queryMap.length != 1) {
          String debug =
              'Error retrieving tag in table: $tags_table, Tags found: ${queryMap.length}';
          throw Exception(debug);
        }

        idTagUpserted = queryMap[0][tagIdColumn] as int;
      }
    } else {
      //On tag update
      int rowsUpdated = await db.update(tags_table, tagMap,
          where: '$tagIdColumn = ?', whereArgs: [tagModel.tagId]);

      if (rowsUpdated == null || rowsUpdated <= 0) {
        throw 'Error on updating tag!';
      }

      idTagUpserted = tagModel.tagId;
    }

    if (idTagUpserted == null || idTagUpserted <= 0) {
      throw 'Invalid TagID inserted!';
    }

    return idTagUpserted;
  }

  ///Searches tags that match a certain [String].
  static Future<List<TagModel>> queryByName(String query, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

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
  static Future<List<TagModel>> queryByEntryId(int entryId,
      [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

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
    var readOnlyList = await db.rawQuery(querySql, [entryId]);

    List<Map<String, dynamic>> tagsQuery = [];
    readOnlyList.forEach((element) {
      Map<String, dynamic> map = Map<String, dynamic>.from(element);
      tagsQuery.add(map);
    });

    List<TagModel> tagsList = [];
    tagsQuery.forEach((tagQueryMap) {
      TagModel tag = TagModel.fromMap(tagQueryMap);
      tagsList.add(tag);
    });

    return tagsList;
  }
}
