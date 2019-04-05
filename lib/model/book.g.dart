// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book(
      id: json['id'] as String,
      name: json['name'] as String,
      cover: json['cover'] as String,
      author: json['author'] as String,
      status: _$enumDecodeNullable(_$BookStatusEnumMap, json['status']),
      category: json['category'] as String,
      introduction: json['introduction'] as String,
      latestChapter: json['latestChapter'] as String);
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover': instance.cover,
      'author': instance.author,
      'status': _$BookStatusEnumMap[instance.status],
      'category': instance.category,
      'introduction': instance.introduction,
      'latestChapter': instance.latestChapter
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$BookStatusEnumMap = <BookStatus, dynamic>{
  BookStatus.BOOK_SERIALIZING: 'BOOK_SERIALIZING',
  BookStatus.BOOK_END: 'BOOK_END'
};
