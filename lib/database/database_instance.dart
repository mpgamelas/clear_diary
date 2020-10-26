import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseInstance {
  static const _databaseName = "clear_diary.db";
  static const _databaseVersion = 1;

  static const entry_table = 'entries';
  static const tags_table = 'tags';
  static const entry_tag_table = 'entries_tags';

  static const entryId = 'entry_id';
  static const entryDateCreated = 'date_created';
  static const entryDateModified = 'date_modified';
  static const entryDateAssigned = 'date_assigned';
  static const entryTitle = 'title';
  static const entryBody = 'body';

  static const tagId = 'tag_id';
  static const tagDateCreated = 'date_created';
  static const tagDateModified = 'date_modified';
  static const tag = 'tag';

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
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL to create tables on the first time
  Future _onCreate(Database db, int version) async {
    String dbCreateCommand = '''
          CREATE TABLE IF NOT EXISTS $entry_table (
            $entryId INTEGER PRIMARY KEY,
            $entryDateCreated INTEGER NOT NULL,
            $entryDateModified INTEGER NOT NULL,
            $entryDateAssigned INTEGER,
            $entryTitle TEXT,
            $entryBody TEXT
          );
          CREATE TABLE IF NOT EXISTS $tags_table (
            $tagId INTEGER PRIMARY KEY,
            $tagDateCreated INTEGER NOT NULL,
            $tagDateModified INTEGER NOT NULL,
            $tag TEXT NOT NULL
          );
          CREATE TABLE IF NOT EXISTS $entry_tag_table (
            $entryId INTEGER NOT NULL,
            $tagId INTEGER NOT NULL,
            FOREIGN KEY($entryId) REFERENCES $entry_table($entryId)
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            FOREIGN KEY($tagId) REFERENCES $tags_table($tagId)
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            UNIQUE($entryId, $tagId)
          );
          ''';
    await db.execute(dbCreateCommand);
  }

  // métodos Helper
  //----------------------------------------------------
  // inserts entry into table
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(entry_table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(entry_table);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $entry_table'));
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[entryId];
    return await db
        .update(entry_table, row, where: '$entryId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(entry_table, where: '$entryId = ?', whereArgs: [id]);
  }
}
