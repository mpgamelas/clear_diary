import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

class TagModel extends Tagging.Taggable {
  int tagId = -1;

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
}
