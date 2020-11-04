import 'dart:io';

import 'package:clear_diary/database/database_instance.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sqflite/sqlite_api.dart';

class Preferences extends StatefulWidget {
  static const String id = 'preferences_screen';

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.preferences),
      ),
      body: PreferenceBody(),
    );
  }
}

class PreferenceBody extends StatefulWidget {
  @override
  _PreferenceBodyState createState() => _PreferenceBodyState();
}

class _PreferenceBodyState extends State<PreferenceBody> {
  bool switchValue = false;

  ///Creates a backup of the database in the external cache directory (wherever that is).
  ///todo: make a proper backup in a better place. (seems hard).
  Future<String> backupFunction() async {
    List<Directory> dir = await getExternalCacheDirectories();
    Database db = await DatabaseInstance.instance.database;
    File dbOrigin = File(db.path);
    File dirNew =
        await dbOrigin.copy('${dir[0].path}/${DateTime.now().toString()}.db');

    return dirNew.path;
  }

  ///todo: complete
  Future<String> restoreFunction() async {
    Database db = await DatabaseInstance.instance.database;
    File dbOrigin = File(db.path);

    DatabaseInstance.clearInstance();

    List<Directory> dir = await getExternalCacheDirectories();
    Directory dbBackupDir = dir[0];

    String newDbPath = '${dir[0].path}/${DateTime.now().toString()}.db';
    File dirNew = await dbOrigin.copy(newDbPath);

    return dirNew.path;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Strings.backupRestore,
          tiles: [
            SettingsTile(
              title: Strings.backup,
              leading: Icon(Icons.backup),
              onTap: () async {
                String path = await backupFunction();
                String msg = 'Backup created at: ' + path;
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
            ),
            SettingsTile(
              title: Strings.restore,
              leading: Icon(Icons.restore),
              onTap: () async {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Not implemented')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
