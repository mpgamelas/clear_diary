import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/values/strings.dart';
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
    String entryIdInfo = Strings.cardEntryId + entry.entryId.toString();
    String dateCreatedInfo =
        Strings.cardDateCreated + entry.dateCreated.toString();
    String dateModifiedInfo =
        Strings.cardDateModified + entry.dateModified.toString();
    String dateAssignedInfo =
        Strings.cardDateAssigned + entry.dateAssigned.toString();

    return Card(
      child: InkWell(
        splashColor: Values.cardColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntry(entry)),
          );
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                  title: Text(Strings.cardEntryDetails),
                  contentPadding: EdgeInsets.all(8.0),
                  children: [
                    Text(entryIdInfo),
                    Text(dateCreatedInfo),
                    Text(dateModifiedInfo),
                    Text(dateAssignedInfo),
                  ],
                );
              });
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
