import 'package:flutter/material.dart';

///Holds the state for the system theme (light, dark or system default).
///On older devices seems to default to light.
class ThemeState with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeState({ThemeMode mode = ThemeMode.system}) : _mode = mode;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  ///An ugly hack, todo: fix this.
  void setModeString(String modeString) {
    if (modeString == 'System') {
      setMode(ThemeMode.system);
    } else if (modeString == 'Dark') {
      setMode(ThemeMode.dark);
    } else if (modeString == 'Light') {
      setMode(ThemeMode.light);
    } else {
      throw Exception('Invalid string!');
    }
  }
}
