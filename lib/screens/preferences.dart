import 'dart:io';

import 'package:clear_diary/State/home_state.dart';
import 'package:clear_diary/State/theme_state.dart';
import 'package:clear_diary/database/database_instance.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:provider/provider.dart';

///Screen of preferences.
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
              onPressed: (context) {
                backupData();
              },
            ),
            SettingsTile(
              title: Strings.restore,
              leading: Icon(Icons.restore),
              onPressed: (context) {
                restoreData();
              },
            ),
            SettingsTile(
              title: Strings.deleteBackups,
              leading: Icon(Icons.delete_forever),
              onPressed: (context) {
                deleteData();
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

  void backupData() async {
    String path = await DatabaseInstance.backupData();
    String msg = Strings.backupCreatedAt + path;
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void restoreData() async {
    File fileChosen = await dialogChooseBackup();
    if (fileChosen == null) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(Strings.noFilesChosenDialog)));
    } else {
      try {
        await DatabaseInstance.restoreFunction(fileChosen);
      } catch (exc, stack) {
        //todo: log something
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(Strings.errorRestoreBackup)));
      }

      //todo: test this here
      Provider.of<HomeState>(context, listen: false).queryEntries();
    }
  }

  ///Opens dialog for choosing a backupfile
  Future<File> dialogChooseBackup() async {
    Directory dbBackupDir = await DatabaseInstance.getBackupDir();

    List<FileSystemEntity> listFiles =
        dbBackupDir.listSync(recursive: false, followLinks: false);

    if (listFiles.isEmpty) {
      return null;
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

    return backupChosen;
  }

  ///Restores the database from a previous backup.
  ///todo: put this on another place
  Future<String> restoreFunction(File backupFile) async {
    Database db = await DatabaseInstance.instance.database;

    File dbOrigin = File(db.path);

    File dirNew;
    try {
      dirNew = await backupFile.copy(dbOrigin.path);
    } catch (e) {
      //todo: log here
      print(e);
      return Strings.errorRestoreBackup;
    }

    Provider.of<HomeState>(context, listen: false).queryEntries();

    return Strings.restoreSuccessful;
  }

  void deleteData() async {
    await DatabaseInstance.deleteBackups();
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text(Strings.backupsDeleted)));
  }
}
