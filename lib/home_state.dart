import 'package:flutter/material.dart';

import 'database/entry_contract.dart';
import 'models/entry_model.dart';

///Holds the state for the Home screen
///Does not seem like the best idea, but as longs as it works it should be fine for now.
class HomeState with ChangeNotifier {
  List<EntryModel> _homeEntriesList;

  List<EntryModel> get homeEntriesList => _homeEntriesList;

  HomeState() {
    this.queryEntries();
  }

  ///Default query for entries in the current month to the last month of the year
  void queryEntries() {
    //todo: parameters here to change the query dates.

    DateTime now = DateTime.now();
    DateTime currentMonthStart = DateTime(now.year, now.month);
    DateTime currentYearEnd = DateTime(now.year, 12, 31, 11);
    queryEntriesRange(currentMonthStart, currentYearEnd);
  }

  ///Query entries by a date range.
  void queryEntriesRange(DateTime start, DateTime end) async {
    _homeEntriesList = await EntryContract.queryByDate(start, end);

    notifyListeners();
  }
}
