import 'package:clear_diary/database/database_instance.dart';
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

  EntryModel.fromMap(Map<String, dynamic> map) {
    //todo: here
  }
}
