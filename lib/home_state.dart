import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/entry_contract.dart';
import 'models/entry_model.dart';

///Holds the state for the Home screen
///Does not seem like the best idea, but as longs as it works it should be fine for now.
class HomeState with ChangeNotifier {
  static const String prefDataQueryBegin = 'pref_data_query_begin';
  static const String prefDataQueryEnd = 'pref_data_query_end';

  List<EntryModel> _homeEntriesList;
  DateTime dataQueryBegin;
  DateTime dataQueryEnd;

  List<EntryModel> get homeEntriesList => _homeEntriesList;

  HomeState() {
    this.queryEntries();
  }

  ///Default query for entries in the current month to the last month of the year
  void queryEntries() async {
    var prefs = await SharedPreferences.getInstance();

    final beginMiliseg = prefs.getInt(prefDataQueryBegin);
    final endMiliseg = prefs.getInt(prefDataQueryEnd);

    if (beginMiliseg == null || endMiliseg == null) {
      DateTime now = DateTime.now();
      DateTime currentMonthStart = DateTime(now.year, now.month);
      DateTime currentYearEnd = DateTime(now.year, 12, 31, 11);

      dataQueryBegin = currentMonthStart;
      dataQueryEnd = currentYearEnd;

      prefs.setInt(prefDataQueryBegin, dataQueryBegin.millisecondsSinceEpoch);
      prefs.setInt(prefDataQueryEnd, dataQueryEnd.millisecondsSinceEpoch);
    } else {
      dataQueryBegin = DateTime.fromMillisecondsSinceEpoch(beginMiliseg);
      dataQueryEnd = DateTime.fromMillisecondsSinceEpoch(endMiliseg);
    }
    queryEntriesRange(dataQueryBegin, dataQueryEnd);
  }

  ///Query entries by a date range.
  void queryEntriesRange(DateTime start, DateTime end) async {
    _homeEntriesList = await EntryContract.queryByDate(start, end);

    notifyListeners();
  }
}
