import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/text_field_tags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DiaryEntry extends StatelessWidget {
  static const String id = 'diary_entry_screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Strings.newEntry),
        ),
        body: DiaryEntryBody(),
      ),
    );
  }
}

class DiaryEntryBody extends StatefulWidget {
  @override
  _DiaryEntryBodyState createState() => _DiaryEntryBodyState();
}

class _DiaryEntryBodyState extends State<DiaryEntryBody> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  final String entryDateKey = 'entry_date';
  final String entryTitleKey = 'entry_title';
  final String entryTagsKey = 'entry_tags';
  final String entryBodyKey = 'entry_body';

  EntryModel entryPassed;
  Function callBack;
  DateTime defaultDate = DateTime.now();
  String defaultTitle = '';
  List<TagModel> defaultTags = [];
  String defaultBody = '';

  @override
  void initState() {
    super.initState();

    //necessary to get arguments
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   getPassedEntry();
    // });
  }

  ///Used to set the fields to default values
  void getPassedEntry() {
    try {
      DiaryEntryArguments args = ModalRoute.of(context).settings.arguments;
      entryPassed = args.entry;
      callBack = args.callBack;
    } catch (e) {
      print(e);
      entryPassed = null;
      callBack = null;
    }

    bool isUpdate = entryPassed != null && entryPassed.entryId > 0;
    if (isUpdate) {
      defaultDate = entryPassed.dateAssigned;
      defaultTitle = entryPassed.title;
      defaultTags = entryPassed.tags;
      defaultBody = entryPassed.body;
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

      bool isUpdate = entryPassed != null && entryPassed.entryId > 0;

      EntryModel updateEntry = EntryModel(
        dateCreated: isUpdate ? entryPassed.dateCreated : DateTime.now(),
        dateModified: DateTime.now(),
        dateAssigned: entryDate,
        title: entryTitle,
        body: entryBody,
        tags: entryTags,
      );
      await EntryContract.save(updateEntry);

      if (callBack != null) {
        callBack();
      }
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    getPassedEntry();

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

class DiaryEntryArguments {
  EntryModel entry;
  Function callBack;

  DiaryEntryArguments(this.entry, this.callBack);
}
