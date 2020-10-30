import 'package:clear_diary/database/tag_contract.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

class TextFieldTags extends StatefulWidget {
  final FormFieldState<dynamic> formField;

  TextFieldTags(this.formField);

  @override
  _TextFieldTagsState createState() => _TextFieldTagsState();
}

class _TextFieldTagsState extends State<TextFieldTags> {
  List<TagModel> _tagList;

  @override
  void initState() {
    super.initState();
    _tagList = widget.formField.value;
  }

  @override
  void dispose() {
    _tagList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tagging.FlutterTagging<TagModel>(
      initialItems: _tagList,
      textFieldConfiguration: Tagging.TextFieldConfiguration(
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.teal.withAlpha(30),
          hintText: Strings.searchTags,
          labelText: Strings.selectTags,
        ),
      ),
      findSuggestions: TagContract.queryByName,
      additionCallback: (value) {
        DateTime now = DateTime.now();
        return TagModel(value, dateCreated: now, dateModified: now);
      },
      onAdded: (tagModel) {
        // api calls here, triggered when add to tag button is pressed
        return tagModel;
      },
      configureSuggestion: (tagModel) {
        return Tagging.SuggestionConfiguration(
          title: Text(tagModel.tag),
          additionWidget: Chip(
            avatar: Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
            label: Text(Strings.addNewTag),
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
            backgroundColor: Colors.teal,
          ),
        );
      },
      configureChip: (tagModel) {
        return Tagging.ChipConfiguration(
          label: Text(tagModel.tag),
          backgroundColor: Colors.teal,
          labelStyle: TextStyle(color: Colors.white),
          deleteIconColor: Colors.white,
        );
      },
      onChanged: () {
        setState(() {
          widget.formField.didChange(_tagList);
        });
      },
    );
  }
}
