import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/models/tag_model.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/entry_card.dart';
import 'package:clear_diary/widgets/tag_selector.dart';
import 'file:///L:/MarioProjetos/Flutter/clear_diary/lib/database/contract/entry_contract.dart';
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

  List<EntryModel> searchResults = [];

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
    Widget searchView;

    if (searchResults.isEmpty) {
      searchView = const Center(child: Text(Strings.noResultsToShow));
    } else {
      searchView = Expanded(
        child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            return EntryCard(searchResults[index]);
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
          searchView,
        ],
      ),
    );
  }

  void changedDropDownItem(String selectedOption) {
    print("Selected $selectedOption");
  }

  Future<void> onTagsSearchedChanged(List<TagModel> tagList) async {
    var entriesList = await EntryContract.queryByTags(tagList);
    setState(() {
      searchResults = entriesList;
    });
  }
}
