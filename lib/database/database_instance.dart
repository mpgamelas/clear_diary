import 'dart:io';

import 'package:clear_diary/values/strings.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_scripts.dart';

class DatabaseInstance {
  static const _databaseName = "clear_diary.db";
  static final _databaseVersion = migrationScripts.length;

  // makes a singleton class, not sure if it is nice idea
  DatabaseInstance._privateConstructor();
  static final DatabaseInstance instance =
      DatabaseInstance._privateConstructor();

  // single reference to the DB.
  static Database _database;

  Future<Database> get database async {
    if (_database != null && _database.isOpen) return _database;
    // creates DB instance on first time
    _database = await _initDatabase();
    return _database;
  }

  // opens DB and creates it on the first run
  _initDatabase() async {
    // count the number of scripts to define the version of the database
    int nbrMigrationScripts = migrationScripts.length;

    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);

    var db = await openDatabase(path, version: nbrMigrationScripts,

        /// if the database does not exist, onCreate executes all the sql requests of the "migrationScripts" map
        onCreate: (Database db, int version) async {
      for (int i = 1; i <= nbrMigrationScripts; i++) {
        List<String> listScripts = migrationScripts[i];
        for (String script in listScripts) {
          await db.execute(script);
        }
      }
    },

        /// if the database exists but the version of the database is different
        /// from the version defined in parameter, onUpgrade will execute all sql requests greater than the old version
        onUpgrade: (db, oldVersion, newVersion) async {
      for (int i = oldVersion + 1; i <= newVersion; i++) {
        List<String> listScripts = migrationScripts[i];
        for (String script in listScripts) {
          await db.execute(script);
        }
      }
    }, onConfigure: (db) async {
      for (String script in configureScripts) {
        await db.execute(script);
      }
    });
    return db;
  }

  ///Return default backup directory
  static Future<Directory> getBackupDir() async {
    List<Directory> dir = await getExternalCacheDirectories();
    Directory cacheDir = dir[0];
    String newBackupDir = cacheDir.path + Platform.pathSeparator + 'backups';
    Directory backupDir =
    await Directory(newBackupDir).create(recursive: false);

    return backupDir;
  }

  ///Delete all backups
  static Future<void> deleteBackups() async {
    Directory bkpDir = await getBackupDir();
    bkpDir.deleteSync(recursive: true);
  }

  ///Creates Backup on default directory
  static Future<String> backupData() async {
    Directory dir = await getBackupDir();

    Database db = await DatabaseInstance.instance.database;
    if (db.isOpen) {
      await db.close();
    }
    File dbOrigin = File(db.path);

    String timeStamp = DateTime.now().toString();
    String newBackupFile = dir.path + Platform.pathSeparator + '$timeStamp.db';
    File dirNew = await dbOrigin.copy(newBackupFile);

    if (!db.isOpen) {
      db = null;
      db = await DatabaseInstance.instance.database;
    }

    return dirNew.path;
  }

  ///Restores the database from a previous backup.
  ///Check https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md
  ///for a better solution?
  static Future<void> restoreFunction(File backupFile) async {
    Database db = await DatabaseInstance.instance.database;
    File dbOrigin = File(db.path);
    File dirNew = await backupFile.copy(dbOrigin.path);
  }
}
