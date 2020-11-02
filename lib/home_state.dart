import 'package:flutter/material.dart';

import 'database/entry_contract.dart';
import 'models/entry_model.dart';

///Holds the state for the Home screen
///Does not seem like the best idea, but as longs as it works it should be fine for now.
///todo: change the query dates.
class HomeState with ChangeNotifier {
  List<EntryModel> _homeEntriesList = [];

  List<EntryModel> get homeEntriesList => _homeEntriesList;

  HomeState() {
    this.queryEntries(DateTime(2020), DateTime.now());
  }

  void queryEntries(DateTime start, DateTime end) async {
    _homeEntriesList = await EntryContract.queryByDate(start, end);

    notifyListeners();
  }
}
