import 'package:clear_diary/database/database_instance.dart';
import 'package:clear_diary/database/log_contract.dart';
import 'package:clear_diary/models/log_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

///Error level classification:
///
///[log] is for debug/small errors, where the user probably will not notice anything.
///
///[warning] is for more serious mistakes, where the user can feel something is wrong, but the app can
///still work nonetheless.
///
///[error] for more serious errors that stop the user from doing something, or even can crash the app if unhandled.
///
///[critical] for major mistakes in the programming, need to be fixed ASP, should never happen in production
enum ErrorLevel { log, warning, error, critical }

///Simple logging system, stores errors in the SQLite.
class Logger {

  ///Prefix for log messages in the console
  static const String prefix = 'logger_clear_diary';

  ///Helper log message.
  static void logSimples(String msgLog, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    if (kDebugMode) {
      print('$prefix Debug: $msgLog');
    }

    Logger.log(msgLog, null, null, ErrorLevel.log, db);
  }

  ///Helper function for warnings
  static void warning(String msgWarning, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    if (kDebugMode) {
      print('$prefix Warning!: $msgWarning');
    }

    Logger.log(msgWarning, null, null, ErrorLevel.warning, db);
  }

  ///Helper function for exceptions.
  static void error(Exception exc, StackTrace stack, [Database db]) async {
    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    if (kDebugMode) {
      StringBuffer strBuff = StringBuffer();
      strBuff.writeln('Exception detected by the Logger!');
      strBuff.writeln('Follows exc.toString:${exc.toString()}');
      strBuff.writeln('Follows stack.toString:${stack.toString()}');
      print(strBuff.toString());
    }

    Logger.log('Exception caught!', exc, stack, ErrorLevel.error);
  }

  ///General log function.
  static Future<void> log(
      String msgDebug, dynamic exception, StackTrace stack, ErrorLevel level,
      [Database db]) async {

    //should crash the app, but let's keep going to see what happens
    if (exception is Error) {
      msgDebug = 'FATAL ERROR!!!\n\n' + msgDebug;
      level = ErrorLevel.critical;
    }

    //Check if storing the log is necessary on production.
    if (!kDebugMode && level == ErrorLevel.log){
      return; //can be skipped here
    }

    if (db == null) {
      db = await DatabaseInstance.instance.database;
    }

    String exceptxt = '';
    String stactTxt = '';
    if (exception != null) {
      exceptxt = exception.toString();
    }

    //For some reason the stack comes empty or null from the try catch
    if (stack != null && stack.toString().isNotEmpty) {
      stactTxt = stack.toString();
    } else {
      stactTxt = StackTrace.current.toString();
    }

    var temp = LogModel(msgDebug, exceptxt, stactTxt, level);
    LogContract.save(temp, db);
  }
}
