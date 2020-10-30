import 'package:clear_diary/database/tag_contract.dart';
import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

class TagModel extends Tagging.Taggable {
  int tagId;

  DateTime dateCreated;
  DateTime dateModified;

  String tag;

  TagModel(
    this.tag, {
    this.tagId,
    this.dateCreated,
    this.dateModified,
  });

  @override
  List<Object> get props => [tag];

  TagModel.fromMap(Map<String, dynamic> readOnlyMap) {
    tagId = readOnlyMap[TagContract.tagIdColumn];

    dateCreated = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[TagContract.tagDateCreatedColumn]);
    dateModified = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[TagContract.tagDateModifiedColumn]);

    tag = readOnlyMap[TagContract.tagColumn];
  }
}
