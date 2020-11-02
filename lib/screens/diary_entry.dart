import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/text_field_tags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final String entryDateKey = 'entry_date';
  final String entryTitleKey = 'entry_title';
  final String entryTagsKey = 'entry_tags';
  final String entryBodyKey = 'entry_body';

  DateTime defaultDate = DateTime.now();
  String defaultTitle = '';
  List<TagModel> defaultTags = [];
  String defaultBody = '';
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();

    //Initialize default values
    final EntryModel entry = widget.entry;
    isUpdate = entry.isRecorded();
    if (isUpdate) {
      defaultDate = entry.dateAssigned;
      defaultTitle = entry.title;
      defaultTags = entry.tags;
      defaultBody = entry.body;
    } else {
      final now = DateTime.now();
      final lastMidnight = new DateTime(now.year, now.month, now.day);
      defaultDate = lastMidnight;
    }
  }

  ///onClick method of Save button
  void saveEntry() async {
    if (_fbKey.currentState.saveAndValidate()) {
      DateTime entryDate = _fbKey.currentState.value[entryDateKey] as DateTime;
      String entryTitle = _fbKey.currentState.value[entryTitleKey] as String;
      List<TagModel> entryTags =
          _fbKey.currentState.value[entryTagsKey] as List<TagModel>;
      String entryBody = _fbKey.currentState.value[entryBodyKey] as String;

      EntryModel updateEntry = EntryModel(
        dateCreated: isUpdate ? widget.entry.dateCreated : DateTime.now(),
        dateModified: DateTime.now(),
        dateAssigned: entryDate,
        title: entryTitle,
        body: entryBody,
        tags: entryTags,
      );
      await EntryContract.save(updateEntry);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      children: <Widget>[
        FormBuilder(
          key: _fbKey,
          initialValue: {
            entryDateKey: defaultDate,
            entryTitleKey: defaultTitle,
            entryTagsKey: defaultTags,
            entryBodyKey: defaultBody,
          },
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: <Widget>[
              FormBuilderCustomField(
                attribute: entryTagsKey,
                validators: [],
                formField: FormField(
                  enabled: true,
                  builder: (FormFieldState<dynamic> field) {
                    return TextFieldTags(field);
                  },
                ),
              ),
              FormBuilderDateTimePicker(
                attribute: entryDateKey,
                inputType: InputType.date,
                format: DateFormat("dd-MM-yyyy"),
                decoration: InputDecoration(labelText: Strings.entryDate),
              ),
              FormBuilderTextField(
                attribute: entryTitleKey,
                decoration: InputDecoration(labelText: Strings.entryTitle),
                validators: [],
              ),
              FormBuilderTextField(
                attribute: entryBodyKey,
                maxLines: null, //important so that text wraps
                decoration: InputDecoration(labelText: Strings.entryText),
                validators: [],
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              child: Text("Save"),
              onPressed: saveEntry,
            ),
            SizedBox(width: 10.0),
            RaisedButton(
              child: Text("Reset"),
              onPressed: () {
                _fbKey.currentState.reset();
              },
            ),
          ],
        )
      ],
    );
  }
}
