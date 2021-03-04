import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/text_field_tags.dart';
import 'package:flutter/material.dart';

class DiaryEntry extends StatefulWidget {
  static const String id = 'diary_entry_screen';

  final EntryModel entry;

  DiaryEntry(this.entry);

  @override
  _DiaryEntryState createState() => _DiaryEntryState();
}

class _DiaryEntryState extends State<DiaryEntry> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entry.isRecorded()
              ? Strings.updateEntry
              : Strings.newEntry),
        ),
        body: DiaryEntryBody(widget.entry),
      ),
    );
  }
}

class DiaryEntryBody extends StatefulWidget {
  final EntryModel entry;

  DiaryEntryBody(this.entry);

  @override
  _DiaryEntryBodyState createState() => _DiaryEntryBodyState();
}

class _DiaryEntryBodyState extends State<DiaryEntryBody> {
  DateTime chosenDate = DateTime.now();
  String title = '';
  String body = '';
  List<TagModel> tagList = [];

  ///onClick method of Save button
  void saveEntry() async {
    bool varrt = tagList.isEmpty;
    print('save pressed');

    /*
      EntryModel updateEntry = EntryModel(
        entryId: isUpdate ? widget.entry.entryId : null,
        dateCreated: isUpdate ? widget.entry.dateCreated : DateTime.now(),
        dateModified: DateTime.now(),
        dateAssigned: entryDate,
        title: entryTitle,
        body: entryBody,
        tags: entryTags,
      );
      await EntryContract.save(updateEntry);

      Provider.of<HomeState>(context, listen: false).queryEntries();
      Navigator.of(context).pop();
       */
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      children: <Widget>[
        TextFieldTags(tagList),
        TextField(
          decoration: InputDecoration(labelText: Strings.entryDate,),
          readOnly: true,
          onTap: () {
            setEntryDate();
          },
        ),
        TextField(decoration: InputDecoration(labelText: Strings.entryTitle)),
        TextField(
          decoration: InputDecoration(labelText: Strings.entryText),
          maxLines: null,
        ),
        Row(
          children: <Widget>[
            ElevatedButton(
              child: Text(Strings.save),
              onPressed: saveEntry,
            ),
          ],
        )
      ],
    );
  }


  void setEntryDate(){
  }
}
