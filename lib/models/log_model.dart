import 'file:///L:/MarioProjetos/Flutter/clear_diary/lib/database/contract/log_contract.dart';
import 'package:clear_diary/logger.dart';

class LogModel{
  int idLog;
  String debug;
  String exception;
  String stack;
  DateTime date;
  ErrorLevel level;

  LogModel(String debugInfo, String exception, String stack, ErrorLevel level){
    debug = debugInfo ?? '';
    exception = exception ?? '';
    stack = stack ?? '';
    date = DateTime.now();
    level = level ?? ErrorLevel.error;
  }

  LogModel.fromMap(Map<String, dynamic> readOnlyMap) {
    debug = readOnlyMap[LogContract.debugColumn];
    exception = readOnlyMap[LogContract.exceptionColumn];
    stack = readOnlyMap[LogContract.stackColumn];
    date = DateTime.fromMillisecondsSinceEpoch(readOnlyMap[LogContract.dateColumn]);
    level = ErrorLevel.values[readOnlyMap[LogContract.levelColumn]];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      LogContract.debugColumn: this.debug,
      LogContract.exceptionColumn: this.exception,
      LogContract.stackColumn: this.stack,
      LogContract.dateColumn: this.date.millisecondsSinceEpoch,
      LogContract.levelColumn: this.level.index,
    };
    return map;
  }
}