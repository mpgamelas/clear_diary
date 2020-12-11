import 'package:clear_diary/home_state.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/screens/home.dart';
import 'package:clear_diary/screens/preferences.dart';
import 'package:clear_diary/screens/search_entry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(ChangeNotifierProvider(
    create: (_) => HomeState(),
    child: DiaryApp(),
  ));
}

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clear Diary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => Home(),
        Preferences.id: (context) => Preferences(),
        DiaryEntry.id: (context) => DiaryEntry(EntryModel()),
        SearchEntry.id: (context) => SearchEntry(),
      },
    );
  }
}
