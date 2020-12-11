import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/tag_model.dart';

class EntryModel {
  int _entryId = -1;

  DateTime dateCreated;
  DateTime dateModified;
  DateTime dateAssigned;

  String title;
  String body;
  List<TagModel> tags;

  int get entryId => _entryId;

  EntryModel(
      {int entryId,
      this.dateCreated,
      this.dateModified,
      this.dateAssigned,
      this.title,
      this.body,
      this.tags})
      : _entryId = entryId;

  ///Constructs an [EntryModel] without tags.
  EntryModel.fromMap(Map<String, dynamic> readOnlyMap) {
    _entryId = readOnlyMap[EntryContract.idColumn];

    dateCreated = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[EntryContract.dateCreatedColumn]);
    dateModified = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[EntryContract.dateModifedColumn]);
    dateAssigned = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[EntryContract.dateAssignedColumn]);

    title = readOnlyMap[EntryContract.titleColumn];
    body = readOnlyMap[EntryContract.bodyColumn];

    tags = [];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      EntryContract.dateCreatedColumn: this.dateCreated.millisecondsSinceEpoch,
      EntryContract.dateModifedColumn: this.dateModified.millisecondsSinceEpoch,
      EntryContract.dateAssignedColumn:
          this.dateAssigned.millisecondsSinceEpoch,
      EntryContract.titleColumn: this.title,
      EntryContract.bodyColumn: this.body,
    };

    if (this.isRecorded()) {
      map[EntryContract.idColumn] = this.entryId;
    }

    return map;
  }

  ///Generates a new entry for testing
  EntryModel.test(int index) {
    DateTime origin = DateTime(2020, 1, 1);
    dateCreated = origin.add(Duration(days: index));
    dateModified = origin.add(Duration(days: (index + 1)));
    dateAssigned = origin.add(Duration(days: index));

    title = 'Title $index';
    body = 'Body $index';

    if (index % 3 == 0) {
      tags = [TagModel.test(1), TagModel.test(2), TagModel.test(3)];
    } else if (index % 3 == 1) {
      tags = [TagModel.test(1)];
    } else if (index % 3 == 2) {
      tags = [TagModel.test(1), TagModel.test(2)];
    }
  }

  ///True if the entry has a valid ID.
  bool isRecorded() {
    return entryId != null && entryId > 0;
  }
}
