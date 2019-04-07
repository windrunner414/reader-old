import 'package:json_annotation/json_annotation.dart';

part 'reading_progress.g.dart';

@JsonSerializable()
class ReadingProgress {
  @JsonKey(required: true, disallowNullValue: true, name: 'bookId')
  String bookId;

  @JsonKey(defaultValue: 0, name: 'chapterIndex')
  int chapterIndex;

  @JsonKey(defaultValue: 0, name: 'pageIndex')
  int pageIndex;

  ReadingProgress({this.bookId, this.chapterIndex, this.pageIndex});

  factory ReadingProgress.fromJson(Map<String, dynamic> srcJson) => _$ReadingProgressFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ReadingProgressToJson(this);
}