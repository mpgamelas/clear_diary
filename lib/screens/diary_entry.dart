import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;
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

  EntryModel argumentPassed;
  DateTime defaultDate = DateTime.now();
  String defaultTitle = '';
  List<String> defaultTags = [];
  String defaultBody = '';

  ///Used to set the fields to default values
  @override
  void initState() {
    super.initState();

    try {
      argumentPassed = ModalRoute.of(context).settings.arguments;
    } catch (e) {
      print(e);
      argumentPassed = null;
    }

    bool isUpdate = argumentPassed != null && argumentPassed.entryId > 0;
    if (isUpdate) {
      defaultDate = argumentPassed.dateAssigned;
      defaultTitle = argumentPassed.title;
      defaultTags = argumentPassed.tags;
      defaultBody = argumentPassed.body;
    } else {
      final now = DateTime.now();
      final lastMidnight = new DateTime(now.year, now.month, now.day);
      defaultDate = lastMidnight;
    }
  }

  ///onClick method of Save button
  void saveEntry() {
    if (_fbKey.currentState.saveAndValidate()) {
      DateTime entryDate = _fbKey.currentState.value[entryDateKey] as DateTime;
      String entryTitle = _fbKey.currentState.value[entryTitleKey] as String;
      //List<String> tags = _fbKey.currentState.value[entryTagsKey];
      String entryBody = _fbKey.currentState.value[entryBodyKey] as String;

      bool isUpdate = argumentPassed != null && argumentPassed.entryId > 0;
      if (isUpdate) {
        //todo:update logic here

      } else {
        EntryModel currentEntry = EntryModel(
          dateCreated: DateTime.now(),
          dateModified: DateTime.now(),
          dateAssigned: entryDate,
          title: entryTitle,
          body: entryBody,
        );
        EntryContract.save(currentEntry);
      }

      Navigator.pop(context);
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
              // FormBuilderCustomField(
              //   attribute: entryTagsKey,
              //   validators: [],
              //   formField: FormField(
              //     enabled: true,
              //     builder: (FormFieldState<dynamic> field) {
              //       return TextFieldTags();
              //     },
              //   ),
              // ),
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

///TODO: clean this section
class TextFieldTags extends StatefulWidget {
  @override
  _TextFieldTagsState createState() => _TextFieldTagsState();
}

class _TextFieldTagsState extends State<TextFieldTags> {
  String _selectedValuesJson = 'Nothing to show';

  List<Language> _selectedLanguages;

  @override
  void initState() {
    _selectedLanguages = [];
    super.initState();
  }

  @override
  void dispose() {
    _selectedLanguages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tagging.FlutterTagging<Language>(
      initialItems: _selectedLanguages,
      textFieldConfiguration: Tagging.TextFieldConfiguration(
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.green.withAlpha(30),
          hintText: 'Search Tags',
          labelText: 'Select Tags',
        ),
      ),
      findSuggestions: LanguageService.getLanguages,
      additionCallback: (value) {
        return Language(
          name: value,
          position: 0,
        );
      },
      onAdded: (language) {
        // api calls here, triggered when add to tag button is pressed
        return Language();
      },
      configureSuggestion: (lang) {
        return Tagging.SuggestionConfiguration(
          title: Text(lang.name),
          subtitle: Text(lang.position.toString()),
          additionWidget: Chip(
            avatar: Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
            label: Text('Add New Tag'),
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
            backgroundColor: Colors.teal,
          ),
        );
      },
      configureChip: (lang) {
        return Tagging.ChipConfiguration(
          label: Text(lang.name),
          backgroundColor: Colors.teal,
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      onChanged: () {
        setState(() {
          _selectedValuesJson = _selectedLanguages
              .map<String>((lang) => '\n${lang.toJson()}')
              .toList()
              .toString();
          _selectedValuesJson = _selectedValuesJson.replaceFirst('}]', '}\n]');
        });
      },
    );
  }
}

/// LanguageService
class LanguageService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Language>> getLanguages(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return <Language>[
      Language(name: 'JavaScript', position: 1),
      Language(name: 'Python', position: 2),
      Language(name: 'Java', position: 3),
      Language(name: 'PHP', position: 4),
      Language(name: 'C#', position: 5),
      Language(name: 'C++', position: 6),
    ]
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Language Class
class Language extends Tagging.Taggable {
  ///
  final String name;

  ///
  final int position;

  /// Creates Language
  Language({
    this.name,
    this.position,
  });

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
    "position": $position\n
  }''';
}
