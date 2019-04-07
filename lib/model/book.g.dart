// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'id',
    'name',
    'cover',
    'author',
    'status',
    'category',
    'introduction',
    'latestChapter'
  ], disallowNullValues: const [
    'id',
    'name',
    'cover',
    'author',
    'status',
    'category',
    'introduction',
    'latestChapter'
  ]);
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

Map<String, dynamic> _$BookToJson(Book instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('cover', instance.cover);
  writeNotNull('author', instance.author);
  writeNotNull('status', _$BookStatusEnumMap[instance.status]);
  writeNotNull('category', instance.category);
  writeNotNull('introduction', instance.introduction);
  writeNotNull('latestChapter', instance.latestChapter);
  return val;
}

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
