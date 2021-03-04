import 'package:clear_diary/database/entry_tag_contract.dart';
import 'package:clear_diary/database/log_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';

import 'entry_contract.dart';

///Map with the scripts used for each schema version
final Map<int, List<String>> migrationScripts = {
  1: [createTableEntry, createTableTag, createTableEntryTag],
  2: [createTableLogger],
};

final List<String> configureScripts = [
  pragmaCaseInsensitive,
  pragmaForeignKeys,
];

const String createTableEntry = '''
          CREATE TABLE IF NOT EXISTS ${EntryContract.entry_table} (
            ${EntryContract.idColumn} INTEGER PRIMARY KEY,
            ${EntryContract.dateCreatedColumn} INTEGER NOT NULL,
            ${EntryContract.dateModifedColumn} INTEGER NOT NULL,
            ${EntryContract.dateAssignedColumn} INTEGER,
            ${EntryContract.titleColumn} TEXT,
            ${EntryContract.bodyColumn} TEXT
          );
          ''';

const String createTableTag =
    '''CREATE TABLE IF NOT EXISTS ${TagContract.tags_table} (
            ${TagContract.tagIdColumn} INTEGER PRIMARY KEY,
            ${TagContract.tagDateCreatedColumn} INTEGER NOT NULL,
            ${TagContract.tagDateModifiedColumn} INTEGER NOT NULL,
            ${TagContract.tagColumn} TEXT NOT NULL,
            UNIQUE(${TagContract.tagColumn})
          );''';

const String createTableEntryTag =
    '''CREATE TABLE IF NOT EXISTS ${EntryTagContract.entry_tag_table} (
            ${EntryContract.idColumn} INTEGER NOT NULL,
            ${TagContract.tagIdColumn} INTEGER NOT NULL,
            FOREIGN KEY(${EntryContract.idColumn}) REFERENCES ${EntryContract.entry_table}(${EntryContract.idColumn})
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            FOREIGN KEY(${TagContract.tagIdColumn}) REFERENCES ${TagContract.tags_table}(${TagContract.tagIdColumn})
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            UNIQUE(${EntryContract.idColumn}, ${TagContract.tagIdColumn})
          );
          ''';

const String createTableLogger =
'''CREATE TABLE IF NOT EXISTS ${LogContract.table} (
            ${LogContract.idColumn} INTEGER PRIMARY KEY,
            ${LogContract.debugColumn} TEXT,
            ${LogContract.exceptionColumn} TEXT,
            ${LogContract.stackColumn} TEXT,
            ${LogContract.dateColumn} INTEGER NOT NULL,
            ${LogContract.levelColumn} INTEGER NOT NULL
          );''';

///So that the LIKE operator in SQL is case sensitive.
const String pragmaCaseInsensitive = '''PRAGMA case_sensitive_like = TRUE''';

///So that foreign keys are used.
const String pragmaForeignKeys = '''PRAGMA foreign_keys = ON;''';
