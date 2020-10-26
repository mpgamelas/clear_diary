import 'package:clear_diary/database/database_instance.dart';

class EntryModel {
  int entryId = -1;

  DateTime dateCreated;
  DateTime dateModified;
  DateTime dateAssigned;

  String title;
  String body;
  List<String> tags;

  EntryModel(
      {this.entryId,
      this.dateCreated,
      this.dateModified,
      this.dateAssigned,
      this.title,
      this.body,
      this.tags});
}
