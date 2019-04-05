import 'package:json_annotation/json_annotation.dart';

part 'book_chapter_content.g.dart';

@JsonSerializable()
class BookChapterContent {
  @JsonKey(name: 'content')
  String content;

  BookChapterContent({this.content});

  factory BookChapterContent.fromJson(Map<String, dynamic> srcJson) => _$BookChapterContentFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookChapterContentToJson(this);
}