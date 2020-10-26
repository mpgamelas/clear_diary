import 'package:clear_diary/database/tag_contract.dart';

import 'database_instance.dart';
import 'entry_contract.dart';

final Map<int, String> migrationScripts = {
  1: '''
          CREATE TABLE IF NOT EXISTS ${EntryContract.entry_table} (
            ${EntryContract.idColumn} INTEGER PRIMARY KEY,
            ${EntryContract.dateCreatedColumn} INTEGER NOT NULL,
            ${EntryContract.dateModifedColumn} INTEGER NOT NULL,
            ${EntryContract.dateAssignedColumn} INTEGER,
            ${EntryContract.titleColumn} TEXT,
            ${EntryContract.bodyColumn} TEXT
          );
          CREATE TABLE IF NOT EXISTS ${TagContract.tags_table} (
            ${TagContract.tagId} INTEGER PRIMARY KEY,
            ${TagContract.tagDateCreated} INTEGER NOT NULL,
            ${TagContract.tagDateModified} INTEGER NOT NULL,
            ${TagContract.tag} TEXT NOT NULL
          );
          CREATE TABLE IF NOT EXISTS ${DatabaseInstance.entry_tag_table} (
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
          '''
};
