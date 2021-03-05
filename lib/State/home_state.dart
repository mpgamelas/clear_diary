import 'file:///L:/MarioProjetos/Flutter/clear_diary/lib/database/contract/entry_contract.dart';
import 'package:clear_diary/models/entry_model.dart';
import 'package:flutter/material.dart';

///Holds the state for the Home screen
///Does not seem like the best idea, but as longs as it works it should be fine for now.
class HomeState with ChangeNotifier {
  List<EntryModel> _homeEntriesList;
  DateTime _dataQueryBegin;
  DateTime _dataQueryEnd;

  List<EntryModel> get homeEntriesList => _homeEntriesList;

  HomeState() {
    this.queryEntries();
  }

  ///Default query for entries in the past 10 days to the last month of the year
  void queryEntries() async {
    if (_dataQueryBegin == null || _dataQueryEnd == null) {
      DateTime now = DateTime.now();
      DateTime tenDaysAgo = now.subtract(Duration(days: 10));
      DateTime currentYearEnd = DateTime(now.year, 12, 31, 11);

      _dataQueryBegin = tenDaysAgo;
      _dataQueryEnd = currentYearEnd;
    }
    _queryEntriesRange(_dataQueryBegin, _dataQueryEnd);
  }

  ///Query entries by a date range.
  void _queryEntriesRange(DateTime start, DateTime end) async {
    _homeEntriesList = await EntryContract.queryByDate(start, end);

    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) async {
    _dataQueryBegin = start;
    _dataQueryEnd = end;

    _queryEntriesRange(_dataQueryBegin, _dataQueryEnd);
  }
}
