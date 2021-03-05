import 'package:clear_diary/State/home_state.dart';
import 'file:///L:/MarioProjetos/Flutter/clear_diary/lib/database/contract/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/values/values.dart';
import 'package:clear_diary/widgets/text_field_tags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DiaryEntry extends StatelessWidget {
  static const String id = 'diary_entry_screen';

  final EntryModel entry;

  DiaryEntry(this.entry);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(entry.isRecorded()
              ? Strings.updateEntry
              : Strings.newEntry),
        ),
        body: DiaryEntryBody(entry),
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
  DateTime chosenDate;
  String title = '';
  String body = '';
  List<TagModel> tagList = [];

  ///onClick method of Save button
  void saveEntry() async {
    bool isUpdate = widget.entry.isRecorded();

    EntryModel updateEntry = EntryModel(
      entryId: isUpdate ? widget.entry.entryId : null,
      dateCreated: isUpdate ? widget.entry.dateCreated : DateTime.now(),
      dateModified: DateTime.now(),
      dateAssigned: chosenDate,
      title: title,
      body: body,
      tags: tagList,
    );
    await EntryContract.save(updateEntry);

    Provider.of<HomeState>(context, listen: false).queryEntries();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    if (widget.entry.isRecorded()) {
      title = widget.entry.title;
      body = widget.entry.body;
      tagList = widget.entry.tags;
      chosenDate = widget.entry.dateAssigned;
    } else {
      DateTime now = DateTime.now();
      chosenDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      children: <Widget>[
        TextFieldTags(tagList),
        TextField(
          controller: TextEditingController()
            ..text = DateFormat(Values.dateFormat).format(chosenDate),
          decoration: InputDecoration(
            labelText: Strings.entryDate,
          ),
          readOnly: true,
          onTap: () {
            setEntryDate();
          },
        ),
        TextField(
          decoration: InputDecoration(labelText: Strings.entryTitle),
          controller: TextEditingController()..text = title,
          onChanged: (newText) {
            title = newText;
          },
        ),
        TextField(
          controller: TextEditingController()..text = body,
          decoration: InputDecoration(labelText: Strings.entryText),
          maxLines: null,
          onChanged: (newText) {
            body = newText;
          },
        ),
        ElevatedButton(
          child: Text(Strings.save),
          onPressed: saveEntry,
        )
      ],
    );
  }

  void setEntryDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: chosenDate,
        firstDate: DateTime(2010),
        lastDate: DateTime(2100));

    if (picked != null && picked != chosenDate)
      setState(() {
        chosenDate = picked;
      });
  }
}
