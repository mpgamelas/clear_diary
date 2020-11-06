import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///Card representing a single Entry
class EntryCard extends StatelessWidget {
  final EntryModel entry;

  EntryCard(this.entry);

  @override
  Widget build(BuildContext context) {
    String dateAssigned =
        DateFormat(Values.dateFormat).format(entry.dateAssigned);

    return Card(
      child: InkWell(
        splashColor: Values.cardColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntry(entry)),
          );
        },
        child: Container(
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text(dateAssigned),
          ),
        ),
      ),
    );
  }
}
