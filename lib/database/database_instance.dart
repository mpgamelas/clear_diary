import 'package:path/path.dart';
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
    if (_database != null) return _database;
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
    });
    return db;
  }
}
