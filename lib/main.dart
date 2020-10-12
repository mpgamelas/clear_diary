import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/screens/home.dart';
import 'package:clear_diary/screens/preferences.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: 'pref_');

  PrefService.setDefaultValues({'user_description': 'This is my description!'});

  runApp(DiaryApp());
}

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clear Diary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        Preferences.id: (context) => Preferences(),
        DiaryEntry.id: (context) => DiaryEntry(),
      },
    );
  }
}
