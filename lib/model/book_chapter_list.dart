import 'package:json_annotation/json_annotation.dart';

part 'book_chapter_list.g.dart';

@JsonSerializable()
class BookChapterInfo {
  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'id')
  String id;

  BookChapterInfo({this.title, this.id});

  factory BookChapterInfo.fromJson(Map<String, dynamic> srcJson) => _$BookChapterInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookChapterInfoToJson(this);
}

@JsonSerializable()
class BookChapterList {
  @JsonKey(name: 'chapterList')
  List<BookChapterInfo> chapterList;

  BookChapterList({this.chapterList});

  factory BookChapterList.fromJson(Map<String, dynamic> srcJson) => _$BookChapterListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookChapterListToJson(this);
}
