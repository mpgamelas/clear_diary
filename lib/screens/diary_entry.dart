import 'package:flutter/material.dart';

class DiaryEntry extends StatefulWidget {
  static const String id = 'diary_entry_screen';

  @override
  _DiaryEntryState createState() => _DiaryEntryState();
}

class _DiaryEntryState extends State<DiaryEntry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('titulo teste'),
      ),
      body: Container(
        child: Center(
          child: Text('Teste texo'),
        ),
      ),
    );
  }
}
