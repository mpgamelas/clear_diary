import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class EntryTagContract {
  static const entry_tag_table = 'entries_tags';

  ///Inserts or update the tags of an entry
  static Future<int> save(EntryModel entry) async {
    Database db = await DatabaseInstance.instance.database;

    bool isInsert = entry.entryId == null || entry.entryId <= 0;
    if (isInsert) {
    } else {}
  }

  static Future<List<TagModel>> query(String query) async {}

  static int secondsSinceEpoch(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }
}
