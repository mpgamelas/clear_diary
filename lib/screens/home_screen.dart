import 'package:clear_diary/values/strings.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: HomeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
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
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
