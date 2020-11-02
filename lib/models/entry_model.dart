import 'package:clear_diary/database/entry_contract.dart';
import 'package:clear_diary/models/tag_model.dart';

class EntryModel {
  int entryId = -1;

  DateTime dateCreated;
  DateTime dateModified;
  DateTime dateAssigned;

  String title;
  String body;
  List<TagModel> tags;

  EntryModel(
      {this.entryId,
      this.dateCreated,
      this.dateModified,
      this.dateAssigned,
      this.title,
      this.body,
      this.tags});

  ///Constructs an [EntryModel] without tags.
  EntryModel.fromMap(Map<String, dynamic> readOnlyMap) {
    entryId = readOnlyMap[EntryContract.idColumn];

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

  ///True if the entry has a valid ID.
  bool isRecorded() {
    return entryId != null && entryId > 0;
  }
}
