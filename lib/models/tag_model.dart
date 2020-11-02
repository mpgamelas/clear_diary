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

  Map<String, dynamic> toMap() {
    bool idValid = this.tagId != null && this.tagId > 0;

    Map<String, dynamic> map = {
      TagContract.tagDateCreatedColumn: this.dateCreated.millisecondsSinceEpoch,
      TagContract.tagDateModifiedColumn:
          this.dateModified.millisecondsSinceEpoch,
      TagContract.tagColumn: this.tag,
    };

    if (idValid) {
      map[TagContract.tagIdColumn] = this.tagId;
    }

    return map;
  }

  ///Returns the [TagModel] with the Date Modified already set.
  Map<String, dynamic> toMapModified() {
    var map = this.toMap();
    map[TagContract.tagDateModifiedColumn] =
        DateTime.now().millisecondsSinceEpoch;
    return map;
  }

  ///Returns the [TagModel] with the Date Modified and Date Created already set.
  Map<String, dynamic> toMapNew() {
    var map = this.toMapModified();
    map[TagContract.tagDateCreatedColumn] =
        DateTime.now().millisecondsSinceEpoch;
    return map;
  }
}
