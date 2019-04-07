// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapter_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChapterInfo _$BookChapterInfoFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['title', 'id'],
      disallowNullValues: const ['title', 'id']);
  return BookChapterInfo(
      title: json['title'] as String, id: json['id'] as String);
}

Map<String, dynamic> _$BookChapterInfoToJson(BookChapterInfo instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('id', instance.id);
  return val;
}

BookChapterList _$BookChapterListFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['chapterList'],
      disallowNullValues: const ['chapterList']);
  return BookChapterList(
      chapterList: (json['chapterList'] as List)
          ?.map((e) => e == null
              ? null
              : BookChapterInfo.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$BookChapterListToJson(BookChapterList instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chapterList', instance.chapterList);
  return val;
}
