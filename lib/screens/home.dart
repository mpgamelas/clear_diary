import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/screens/preferences.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  static const String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: HomeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, DiaryEntry.id, arguments: null);
        },
        tooltip: Strings.addEntry,
        child: Icon(Icons.add),
      ),
    );
  }
}

///Main body of initial screen
class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EntryModel>>(
        future: EntryContract.queryByDate(null, null),
        builder:
            (BuildContext context, AsyncSnapshot<List<EntryModel>> snapshot) {
          if (snapshot.hasData) {
            List<EntryModel> entries = snapshot.data;
            //todo: build the listview here
            return Center(
              child: Text('data here'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

///AppBar of the Initialscreen.
///todo: remove the test icons
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Strings.homeScreenTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_alert),
          tooltip: '',
          onPressed: null,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: Strings.settings,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: Strings.settings,
          onPressed: () {
            Navigator.pushNamed(context, Preferences.id);
          },
        ),
      ],
    );
  }

  //Necessary for PreferredSizeWidget, maybe remove it later by embedding the appBar
  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
