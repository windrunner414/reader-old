// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapter_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChapterInfo _$BookChapterInfoFromJson(Map<String, dynamic> json) {
  return BookChapterInfo(
      title: json['title'] as String, id: json['id'] as String);
}

Map<String, dynamic> _$BookChapterInfoToJson(BookChapterInfo instance) =>
    <String, dynamic>{'title': instance.title, 'id': instance.id};

BookChapterList _$BookChapterListFromJson(Map<String, dynamic> json) {
  return BookChapterList(
      chapterList: (json['chapterList'] as List)
          ?.map((e) => e == null
              ? null
              : BookChapterInfo.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$BookChapterListToJson(BookChapterList instance) =>
    <String, dynamic>{'chapterList': instance.chapterList};
