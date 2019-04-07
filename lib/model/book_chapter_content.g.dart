// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapter_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChapterContent _$BookChapterContentFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['content'], disallowNullValues: const ['content']);
  return BookChapterContent(content: json['content'] as String);
}

Map<String, dynamic> _$BookChapterContentToJson(BookChapterContent instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('content', instance.content);
  return val;
}
