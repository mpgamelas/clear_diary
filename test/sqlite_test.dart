import 'dart:io';

import 'package:clear_diary/database/database_scripts.dart';
import 'package:clear_diary/database/tag_contract.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() async {
  // Init ffi loader if needed.
  sqfliteFfiInit();

  DatabaseFactory factory = databaseFactoryFfi;
  Database dbTest = await initializeDatabase(factory);

  test('Initial Test', () async {
    // Should fail table does not exists
    try {
      await dbTest.query('Test');
    } on DatabaseException catch (e) {
      // no such table: Test
      expect(e.isNoSuchTableError('Test'), isTrue);
    }

    // Ok
    await dbTest.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY)');
    await dbTest.execute('ALTER TABLE Test ADD COLUMN name TEXT');
    // should succeed, but empty
    expect(await dbTest.query('Test'), []);

    await dbTest.execute('DROP TABLE Test');
    try {
      await dbTest.query('Test');
    } on DatabaseException catch (e) {
      // no such table: Test
      expect(e.isNoSuchTableError('Test'), isTrue);
    }
  });

  //Test Will fail if order changes
  test('Adding and removing Tag', () async {
    TagModel tagTest = TagModel.test(1);
    int tagIdCreated = await TagContract.save(tagTest, dbTest);
    expect(tagIdCreated, 1);

    List<TagModel> queryResults =
        await TagContract.queryByName(tagTest.tag, dbTest);
    expect(queryResults.length, 1);
    expect(queryResults[0].tag, tagTest.tag);
    expect(queryResults[0].tagId, 1);

    await dbTest.execute('DELETE FROM ${TagContract.tags_table}');
    var teste = await TagContract.queryByName(tagTest.tag, dbTest);
    expect(teste.isEmpty, true);
  });
}

Future<Database> initializeDatabase(DatabaseFactory factory) async {
  // count the number of scripts to define the version of the database
  int nbrMigrationScripts = migrationScripts.length;

  var optionsDb = OpenDatabaseOptions(
      version: nbrMigrationScripts,

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
      },
      onConfigure: (db) async {
        for (String script in configureScripts) {
          await db.execute(script);
        }
      });
  var db = await factory.openDatabase(inMemoryDatabasePath, options: optionsDb);
  return db;
}
