import 'package:flutter/material.dart';

import 'database/entry_contract.dart';
import 'models/entry_model.dart';

///Holds the global state for the app.
///Does not seem like the best idea, but as longs as it works it should be fine for now.
class GlobalState with ChangeNotifier {
  List<EntryModel> _homeEntriesList = [];

  Future<List<EntryModel>> queryEntries(DateTime start, DateTime end) async {
    _homeEntriesList = await EntryContract.queryByDate(start, end);

    notifyListeners();
    return _homeEntriesList;
  }
}
