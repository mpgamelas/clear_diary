import 'package:clear_diary/home_state.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:clear_diary/screens/diary_entry.dart';
import 'package:clear_diary/screens/preferences.dart';
import 'package:clear_diary/screens/search_entry.dart';
import 'package:clear_diary/values/strings.dart';
import 'package:clear_diary/widgets/entry_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeState>(
      builder: (context, global, child) {
        if (global.homeEntriesList == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (global.homeEntriesList.isNotEmpty) {
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: global.homeEntriesList.length,
            itemBuilder: (context, index) {
              return EntryCard(global.homeEntriesList[index]);
            },
          );
        } else {
          return Center(child: Text(Strings.noEntriesForPeriod));
        }
      },
    );
  }
}

///AppBar of the Initialscreen.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  void _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime currentMonthStart = DateTime(now.year, now.month);
    DateTime currentYearEnd = DateTime(now.year, 12, 31, 11);

    DateTimeRange picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: DateTimeRange(
        end: currentYearEnd,
        start: currentMonthStart,
      ),
    );

    Provider.of<HomeState>(context, listen: false)
        .setDateRange(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Strings.homeScreenTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: Strings.setRangeDate,
          onPressed: () {
            _selectDate(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: Strings.search,
          onPressed: () {
            Navigator.pushNamed(context, SearchEntry.id);
          },
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
