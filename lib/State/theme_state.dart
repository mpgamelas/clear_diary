import 'package:clear_diary/values/shared_prefs_keys.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Holds the state for the system theme (light, dark or system default).
///On older devices seems to default to light.
class ThemeState with ChangeNotifier {
  ThemeMode _mode;
  ThemeMode get mode => _mode;
  ThemeState({ThemeMode mode = ThemeMode.system}) {
    _mode = mode; //Guarantees there will be something at start
    getInitialMode(mode);
  }

  static const Map<ThemeMode, String> themeMap = {
    ThemeMode.system: Strings.systemTheme,
    ThemeMode.dark: Strings.darkTheme,
    ThemeMode.light: Strings.lightTheme,
  };

  void getInitialMode(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String themeValue = prefs.getString(SharedPrefsKeys.appTheme) ?? '';
    _mode = themeMap.keys.firstWhere(
        (themeKey) => themeMap[themeKey] == themeValue,
        orElse: () => ThemeMode.system);
    notifyListeners();
  }

  void setMode(ThemeMode mode) async {
    _mode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.appTheme, themeMap[mode]);
    notifyListeners();
  }

  void setModeString(String modeString) {
    ThemeMode themeValue = themeMap.keys
        .firstWhere((themeKey) => themeMap[themeKey] == modeString);

    setMode(themeValue);
  }
}
