import 'package:clear_diary/database/contract/tag_contract.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

///Tag input field. Cannot add new tags to selection.
///todo: see if it can be merged with [TextFieldTags].
class TagSelector extends StatefulWidget {
  final Function onChangedCallback;

  TagSelector({this.onChangedCallback});

  @override
  _TagSelectorState createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  List<TagModel> _tagList = [];

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
      // additionCallback: (value) {
      //   DateTime now = DateTime.now();
      //   return TagModel(value, dateCreated: now, dateModified: now);
      // },
      // onAdded: (tagModel) {
      //   // api calls here, triggered when add to tag button is pressed
      //   return tagModel;
      // },
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
        widget.onChangedCallback(_tagList);
      },
    );
  }
}
