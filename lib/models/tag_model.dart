import 'package:clear_diary/database/contract/tag_contract.dart';
import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

class TagModel extends Tagging.Taggable {
  int _tagId;
  int get tagId => _tagId;

  DateTime dateCreated;
  DateTime dateModified;

  String tag;

  TagModel(
    this.tag, {
    int tagId,
    this.dateCreated,
    this.dateModified,
  }) : _tagId = tagId;

  @override
  List<Object> get props => [tag];

  TagModel.fromMap(Map<String, dynamic> readOnlyMap) {
    _tagId = readOnlyMap[TagContract.tagIdColumn];

    dateCreated = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[TagContract.tagDateCreatedColumn]);
    dateModified = DateTime.fromMillisecondsSinceEpoch(
        readOnlyMap[TagContract.tagDateModifiedColumn]);

    tag = readOnlyMap[TagContract.tagColumn];
  }

  ///True if the tag has a valid ID.
  bool isRecorded() {
    return tagId != null && tagId > 0;
  }

  TagModel.test(int index) {
    DateTime origin = DateTime(2020, 1, 1);
    dateCreated = origin.add(Duration(days: index));
    dateModified = origin.add(Duration(days: (index + 1)));
    tag = 'Tag $index';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      TagContract.tagDateCreatedColumn: this.dateCreated.millisecondsSinceEpoch,
      TagContract.tagDateModifiedColumn: DateTime.now().millisecondsSinceEpoch,
      TagContract.tagColumn: this.tag,
    };

    if (this.isRecorded()) {
      map[TagContract.tagIdColumn] = this.tagId;
    }

    return map;
  }
}
