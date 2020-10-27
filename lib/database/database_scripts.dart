import 'package:clear_diary/database/entry_tag_contract.dart';
import 'package:clear_diary/database/tag_contract.dart';

import 'entry_contract.dart';

///Map with the scripts used for each schema version
final Map<int, List<String>> migrationScripts = {
  1: [
    createTableEntry,
    createTableTag,
    createTableEntryTag,
    pragmaCaseInsensitive
  ]
};

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
            ${TagContract.tagId} INTEGER PRIMARY KEY,
            ${TagContract.tagDateCreated} INTEGER NOT NULL,
            ${TagContract.tagDateModified} INTEGER NOT NULL,
            ${TagContract.tag} TEXT NOT NULL,
            UNIQUE(${TagContract.tag})
          );''';

const String createTableEntryTag =
    '''CREATE TABLE IF NOT EXISTS ${EntryTagContract.entry_tag_table} (
            ${EntryContract.idColumn} INTEGER NOT NULL,
            ${TagContract.tagId} INTEGER NOT NULL,
            FOREIGN KEY(${EntryContract.idColumn}) REFERENCES ${EntryContract.entry_table}(${EntryContract.idColumn})
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            FOREIGN KEY(${TagContract.tagId}) REFERENCES ${TagContract.tags_table}(${TagContract.tagId})
              ON UPDATE CASCADE
              ON DELETE CASCADE,
            UNIQUE(${EntryContract.idColumn}, ${TagContract.tagId})
          );
          ''';

const String pragmaCaseInsensitive = '''PRAGMA case_sensitive_like = TRUE''';
