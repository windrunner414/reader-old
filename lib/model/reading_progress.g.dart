// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingProgress _$ReadingProgressFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['bookId'], disallowNullValues: const ['bookId']);
  return ReadingProgress(
      bookId: json['bookId'] as String,
      chapterIndex: json['chapterIndex'] as int ?? 0,
      pageIndex: json['pageIndex'] as int ?? 0);
}

Map<String, dynamic> _$ReadingProgressToJson(ReadingProgress instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('bookId', instance.bookId);
  val['chapterIndex'] = instance.chapterIndex;
  val['pageIndex'] = instance.pageIndex;
  return val;
}
