import 'dart:io';

import 'package:clear_diary/database/database_scripts.dart';
import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/database/entry_tag_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

///Some tests to check if the database is properly storing information.
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

  test('Adding and removing Tag', () async {
    await addRemoveTag(dbTest);
  });

  test('Adding and removing Entry', () async {
    await addRemoveEntries(dbTest);
  });

  test('Adding entry and updating body', () async {
    await addEntryAndUpdate(dbTest);
  });

  test('Adding entry and delete Tag', () async {
    await addEntryDeleteTag(dbTest);
  });

  //todo: here
  // test('Adding entry with tag and add other entry with same tag', () async {
  //
  // });
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

void cleanDatabase(Database dbTest) async {
  await dbTest.execute('DELETE FROM ${EntryContract.entry_table}');
  await dbTest.execute('DELETE FROM ${TagContract.tags_table}');
  await dbTest.execute('DELETE FROM ${EntryTagContract.entry_tag_table}');

  var entryQuery =
      await dbTest.rawQuery('SELECT * FROM ${EntryContract.entry_table}');
  expect(entryQuery.isEmpty, true);

  var tagQueryTest =
      await dbTest.rawQuery('SELECT * FROM ${TagContract.tags_table}');
  expect(tagQueryTest.isEmpty, true);

  var entryTagQuery = await dbTest
      .rawQuery('SELECT * FROM ${EntryTagContract.entry_tag_table}');
  expect(entryTagQuery.isEmpty, true);
}

void addRemoveTag(Database dbTest) async {
  await dbTest.execute('DELETE FROM ${TagContract.tags_table}');
  TagModel tagTest = TagModel.test(1);
  int tagIdCreated = await TagContract.save(tagTest, dbTest);
  expect(tagIdCreated, 1);

  List<TagModel> queryResults =
      await TagContract.queryByName(tagTest.tag, dbTest);
  expect(queryResults.length, 1);
  expect(queryResults[0].tag, tagTest.tag);
  expect(queryResults[0].tagId, 1);

  cleanDatabase(dbTest);
}

void addRemoveEntries(Database dbTest) async {
  EntryModel entryTest1 = EntryModel.test(1);
  EntryModel entryTest2 = EntryModel.test(2);
  EntryModel entryTest3 = EntryModel.test(3);
  await EntryContract.save(entryTest1, dbTest);
  await EntryContract.save(entryTest2, dbTest);
  await EntryContract.save(entryTest3, dbTest);

  var dateOrigin = DateTime(2020, 1, 1);
  var dateEnd = DateTime(2021, 1, 1);
  List<EntryModel> queryResults =
      await EntryContract.queryByDate(dateOrigin, dateEnd, dbTest);
  expect(queryResults.length, 3);
  expect(queryResults[0].body, entryTest3.body);
  expect(queryResults[1].body, entryTest2.body);
  expect(queryResults[2].body, entryTest1.body);

  expect(queryResults[0].tags.length, 3);
  expect(queryResults[1].tags.length, 2);
  expect(queryResults[2].tags.length, 1);

  cleanDatabase(dbTest);
}

void addEntryAndUpdate(Database dbTest) async {
  EntryModel entryTest1 = EntryModel.test(1);
  EntryModel entryTest2 = EntryModel.test(2);
  EntryModel entryTest3 = EntryModel.test(3);
  try {
    await EntryContract.save(entryTest1, dbTest);
    await EntryContract.save(entryTest2, dbTest);
    await EntryContract.save(entryTest3, dbTest);
  } catch (e) {
    print(e.toString());
  }

  var dateOrigin = DateTime(2020, 1, 1);
  var dateEnd = DateTime(2020, 1, 2);

  var entryQuery = await EntryContract.queryByDate(dateOrigin, dateEnd, dbTest);
  expect(entryQuery.length, 1);
  expect(entryQuery[0].body, entryTest1.body);

  var updateEntry = entryQuery[0];
  updateEntry.body = 'Body 1 modified by test';
  await EntryContract.save(updateEntry, dbTest);

  var newEntryQuery =
      await EntryContract.queryByDate(dateOrigin, dateEnd, dbTest);
  expect(newEntryQuery.length, 1);
  expect(newEntryQuery[0].body, updateEntry.body);

  List<EntryModel> queryResults =
      await EntryContract.queryByDate(DateTime(2020), DateTime(2021), dbTest);
  expect(queryResults.length, 3);
  expect(queryResults[0].body, entryTest3.body);
  expect(queryResults[1].body, entryTest2.body);
  expect(queryResults[2].body, updateEntry.body);

  expect(queryResults[0].tags.length, 3);
  expect(queryResults[1].tags.length, 2);
  expect(queryResults[2].tags.length, 1);

  cleanDatabase(dbTest);
}

void addEntryDeleteTag(Database dbTest) async {
  EntryModel entryTest1 = EntryModel.test(1);

  try {
    await EntryContract.save(entryTest1, dbTest);
  } catch (e) {
    print(e.toString());
  }

  var dateOrigin = DateTime(2020, 1, 1);
  var dateEnd = DateTime(2020, 1, 2);

  var entryQuery = await EntryContract.queryByDate(dateOrigin, dateEnd, dbTest);
  expect(entryQuery.length, 1);
  expect(entryQuery[0].body, entryTest1.body);

  var updateEntry = entryQuery[0];
  updateEntry.body = 'Body 1 modified by test';
  var newTags = [TagModel.test(5), TagModel.test(6)];
  updateEntry.tags = newTags;
  await EntryContract.save(updateEntry, dbTest);

  var newEntryQuery =
      await EntryContract.queryByDate(dateOrigin, dateEnd, dbTest);
  expect(newEntryQuery.length, 1);
  var newEntryUpdated = newEntryQuery[0];
  var updatedTags = newEntryUpdated.tags;
  expect(newEntryUpdated.body, updateEntry.body);

  //failing from here on
  expect(updatedTags.length, newTags.length);
  for (int i = 0; i < updatedTags.length; i++) {
    expect(updatedTags[i].tag, newTags[i].tag);
  }

  cleanDatabase(dbTest);
}
