import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/screens/preferences.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  static const String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: HomeBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntry(EntryModel())),
          );
        },
        tooltip: Strings.addEntry,
        child: Icon(Icons.add),
      ),
    );
  }
}

///Main body of initial screen
class HomeBody extends StatefulWidget {
  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  List<EntryModel> entriesList = [];

  @override
  Widget build(BuildContext context) {
    //todo: check if the query future is being called many times
    return FutureBuilder<List<EntryModel>>(
        future: EntryContract.queryByDate(DateTime(2020), DateTime.now()),
        builder:
            (BuildContext context, AsyncSnapshot<List<EntryModel>> snapshot) {
          if (snapshot.hasData) {
            entriesList = snapshot.data;
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: entriesList.length,
              itemBuilder: (context, index) {
                return EntryCard(entriesList[index]);
              },
            );
          } else if (snapshot.hasError) {
            //todo: log this error somewhere
            return Center(
              child: Text(Strings.anErrorOcurred),
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

///Card representing a single Entry
class EntryCard extends StatelessWidget {
  final EntryModel entry;

  EntryCard(this.entry);

  @override
  Widget build(BuildContext context) {
    String dateAssigned =
        DateFormat(Values.dateFormat).format(entry.dateAssigned);

    return Card(
      child: InkWell(
        splashColor: Values.cardColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryEntry(entry)),
          );
        },
        child: Container(
          child: ListTile(
            title: Text(entry.title),
            subtitle: Text(dateAssigned),
          ),
        ),
      ),
    );
  }
}
