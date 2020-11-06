import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/tag_selector.dart';
import 'package:flutter/material.dart';

class SearchEntry extends StatelessWidget {
  static const String id = 'search_entry_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.searchForAnEntry),
      ),
      body: SearchBody(),
    );
  }
}

///Main body of search screen
class SearchBody extends StatefulWidget {
  @override
  _SearchBodyState createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
  String dropdownValue = Strings.Tag;
  List<String> searchOptions = [
    Strings.Tag,
    Strings.entryTitle,
  ];
  List<DropdownMenuItem<String>> _dropDownMenuItems;

  @override
  void initState() {
    super.initState();
    _dropDownMenuItems = searchOptions.map((optionString) {
      return DropdownMenuItem(
          value: optionString, child: new Text(optionString));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Search By: '),
            trailing: DropdownButton<String>(
              value: dropdownValue,
              items: _dropDownMenuItems,
              onChanged: changedDropDownItem,
            ),
          ),
          TagSelector(
            onChangedCallback: onTagsSearchedChanged,
          ),
        ],
      ),
    );
  }

  void changedDropDownItem(String selectedOption) {
    print("Selected $selectedOption");
  }

  void onTagsSearchedChanged(List<TagModel> tagList) {
    //todo: search by the tags
  }
}
