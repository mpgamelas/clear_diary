import 'package:flutter_tagging/flutter_tagging.dart' as Tagging;

class TagModel extends Tagging.Taggable {
  int tagId;

  DateTime dateCreated;
  DateTime dateModified;

  final String tag;

  TagModel(
    this.tag, {
    this.tagId,
    this.dateCreated,
    this.dateModified,
  });

  @override
  List<Object> get props => [tag];
}
