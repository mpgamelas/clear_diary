import 'package:clear_diary/database/entry_tag_contract.dart';
import 'package:clear_diary/models/log_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import 'database_instance.dart';

class LogContract {
  static const table = 'logger';

  static const idColumn = 'log_id';
  static const debugColumn = 'debug';
  static const exceptionColumn = 'exception';
  static const stackColumn = 'stack';
  static const dateColumn = 'date';
  static const levelColumn = 'level';

  static void save(LogModel model, [Database db]){

  }
}
