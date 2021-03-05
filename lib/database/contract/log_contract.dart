import 'file:///L:/MarioProjetos/Flutter/clear_diary/lib/database/contract/entry_tag_contract.dart';
import 'package:clear_diary/models/log_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqlite_api.dart';

import '../database_instance.dart';

class LogContract {
  static const table = 'logger';

  static const idColumn = 'log_id';
  static const debugColumn = 'debug';
  static const exceptionColumn = 'exception';
  static const stackColumn = 'stack';
  static const dateColumn = 'date';
  static const levelColumn = 'level';

  static void save(LogModel model, [Database db]) async {
    try {
      if (db == null) {
        db = await DatabaseInstance.instance.database;
      }

      db.insert(
        table,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e, stack) {
      //The logger should not fail, ever
      String stackFail = StackTrace.current.toString();
      StringBuffer strBuff = StringBuffer();
      strBuff.writeln('Fatal error on storing the log!');
      strBuff.writeln('Exception: ${e.toString()}');
      strBuff.writeln('Stack: ${stack.toString()}');
      strBuff.writeln('Failsafe stack: $stackFail');

      print(strBuff.toString());

      rethrow;
    }
  }
}
