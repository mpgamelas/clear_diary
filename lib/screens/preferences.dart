import 'dart:convert';
import 'dart:io';

import 'package:clear_diary/State/home_state.dart';
import 'package:clear_diary/State/theme_state.dart';
import 'package:clear_diary/database/database_instance.dart';
import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:provider/provider.dart';

///Screen of preferences.
///todo: refactor to make more sense here, put file access functions elsewhere.
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
  String selectedTheme =
      ThemeState.themeMap.values.toList(growable: false).first;
  List<String> themeValues = ThemeState.themeMap.values.toList(growable: false);
  List<DropdownMenuItem<String>> _dropDownThemeValues;

  @override
  void initState() {
    super.initState();
    _dropDownThemeValues = themeValues.map((themeString) {
      return DropdownMenuItem(value: themeString, child: new Text(themeString));
    }).toList();

    ThemeMode currentTheme =
        Provider.of<ThemeState>(context, listen: false).mode;
    selectedTheme = ThemeState.themeMap[currentTheme];
  }

  ///Creates a backup of the database in the external cache directory (wherever that is).
  ///todo: make a proper backup in a better place. (seems hard).
  ///todo: return a string with message to the user.
  ///todo: This does not work, at all.
  Future<String> backupFunction() async {
    Directory dir = await getBackupDir();
    Database db = await DatabaseInstance.instance.database;
    File dbOrigin = File(db.path);

    String timeStamp = DateTime.now().toString();
    String newBackupFile = dir.path + Platform.pathSeparator + '$timeStamp.db';
    File dirNew = await dbOrigin.copy(newBackupFile);

    return dirNew.path;
  }

  ///Restores the database from a previous backup.
  Future<String> restoreFunction() async {
    Database db = await DatabaseInstance.instance.database;
    File dbOrigin = File(db.path);

    Directory dbBackupDir = await getBackupDir();

    List<FileSystemEntity> listFiles =
        dbBackupDir.listSync(recursive: false, followLinks: false);

    if (listFiles.isEmpty) {
      return Strings.noFilesBackupFolder;
    }

    File backupChosen = await showDialog<File>(
        context: context,
        builder: (BuildContext context) {
          List<Widget> dialogOptions = listFiles.map((file) {
            var completePath = file.path;
            var fileName = (completePath.split(Platform.pathSeparator).last);
            return SimpleDialogOption(
              onPressed: () {
                File chosenBackup = File(completePath);
                Navigator.pop(context, chosenBackup);
              },
              child: Text(fileName),
            );
          }).toList();

          return SimpleDialog(
              title: const Text(Strings.selectDbToRestore),
              children: dialogOptions);
        });

    if (backupChosen == null) {
      return Strings.noFilesChosenDialog;
    }

    File dirNew;
    try {
      dirNew = await backupChosen.copy(dbOrigin.path);
    } catch (e) {
      //todo: log here
      print(e);
      return Strings.errorRestoreBackup;
    }

    Provider.of<HomeState>(context, listen: false).queryEntries();

    return Strings.restoreSuccessful;
  }

  ///Deletes all Backups.
  ///todo: dialog with confirmation here and proper error logs.
  Future<String> deleteBackups() async {
    Directory bkpDir = await getBackupDir();
    try {
      bkpDir.deleteSync(recursive: true);
    } catch (e) {
      print(e);
      return 'Error: ' + e.toString();
    }

    return Strings.backupsDeleted;
  }

  Future<Directory> getBackupDir() async {
    List<Directory> dir = await getExternalCacheDirectories();
    Directory cacheDir = dir[0];
    String newBackupDir = cacheDir.path + Platform.pathSeparator + 'backups';
    Directory backupDir =
        await Directory(newBackupDir).create(recursive: false);

    return backupDir;
  }

  /*
  ///Restores the database from json.
  ///todo debug only, not working properly due to DB locking.
  Future<String> restoreFromJson() async {
    Directory dbBackupDir = await getBackupDir();

    List<FileSystemEntity> listFiles =
        dbBackupDir.listSync(recursive: false, followLinks: false);

    if (listFiles.isEmpty) {
      return Strings.noFilesBackupFolder;
    }

    File backupChosen = File('${dbBackupDir.path}/out.txt');

    if (backupChosen == null) {
      return Strings.noFilesChosenDialog;
    }

    var json = await backupChosen.readAsString();
    var entriesList = jsonToEntry(json);

    await Future.wait(entriesList.map((entry) => EntryContract.save(entry)));

    return 'Sucess ${backupChosen.path}';
  }

  List<EntryModel> jsonToEntry(String json) {
    var obj = jsonDecode(json).cast<Map<String, dynamic>>();

    List<EntryModel> entriesList = [];
    for (Map<String, dynamic> map in obj) {
      String entryBody = map['ConteudoArquivo'];
      String dateCreatedstr = map['DataCriado'];
      String dateModifiedstr = map['DataModificado'];
      String dateAssignedstr = map['DataRegistro'];
      List<dynamic> tagsStrings = map['Tags'];

      DateTime dateCreated = DateTime.tryParse(dateCreatedstr).toLocal();
      DateTime dateModified = DateTime.tryParse(dateModifiedstr).toLocal();
      DateTime dateAssigned = DateTime.tryParse(dateAssignedstr).toLocal();

      DateTime now = DateTime.now();
      List<TagModel> tagsList = tagsStrings
          .map((e) => TagModel(
                e.toString(),
                dateCreated: now,
                dateModified: now,
              ))
          .toList();

      const Map<int, String> diasSemana = {
        1: 'Segunda',
        2: 'Terça',
        3: 'Quarta',
        4: 'Quinta',
        5: 'Sexta',
        6: 'Sábado',
        7: 'Domingo',
      };

      String comp =
          '${dateAssigned.day}/${dateAssigned.month}/${dateAssigned.year}';
      String titulo = '${diasSemana[dateAssigned.weekday]}, Dia ' + comp;
      EntryModel entry = EntryModel(
        title: titulo,
        body: entryBody,
        dateCreated: dateCreated,
        dateModified: dateModified,
        dateAssigned: dateAssigned,
        tags: tagsList,
      );

      entriesList.add(entry);
    }
    return entriesList;
  }
   */

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
                String msg = Strings.backupCreatedAt + path;
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
            ),
            SettingsTile(
              title: Strings.restore,
              leading: Icon(Icons.restore),
              onTap: () async {
                String msg = await restoreFunction();
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
            ),
            SettingsTile(
              title: Strings.deleteBackups,
              leading: Icon(Icons.delete_forever),
              onTap: () async {
                String msg = await deleteBackups();
                Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
              },
            ),
          ],
        ),
        SettingsSection(
          title: Strings.interfaceOptions,
          tiles: [
            SettingsTile(
              title: Strings.appTheme,
              leading: Icon(Icons.brightness_4),
              trailing: DropdownButton<String>(
                value: selectedTheme,
                items: _dropDownThemeValues,
                onChanged: changedDropDownTheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void changedDropDownTheme(String selectedTheme) {
    this.selectedTheme = selectedTheme;
    Provider.of<ThemeState>(context, listen: false)
        .setModeString(selectedTheme);
  }
}
