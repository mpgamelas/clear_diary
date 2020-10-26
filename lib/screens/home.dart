import 'package:clear_diary/database/database_instance.dart';
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
          Navigator.pushNamed(context, DiaryEntry.id);
        },
        tooltip: Strings.addEntry,
        child: Icon(Icons.add),
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('teste'),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dbAcess = DatabaseInstance.instance;

  ///todo: test pending here
  Future<void> insereEntry() async {
    int secondsSinceEpoch =
        (DateTime.now().millisecondsSinceEpoch / 1000) as int;
    Map<String, dynamic> row = {
      //DatabaseInstance.entryId: 1,
      DatabaseInstance.entryDateCreated: secondsSinceEpoch,
      DatabaseInstance.entryDateModified: secondsSinceEpoch,
      DatabaseInstance.entryDateAssigned: secondsSinceEpoch,
      DatabaseInstance.entryTitle: 'title here',
      DatabaseInstance.entryBody: 'body here',
    };
    final id = await dbAcess.insert(row);
    print('linha inserida id: $id');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Strings.homeScreenTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_alert),
          tooltip: 'Show Snackbar',
          onPressed: () {
            final snackBar = SnackBar(content: Text('Scaffold test'));
            Scaffold.of(context).showSnackBar(snackBar);
          },
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

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
