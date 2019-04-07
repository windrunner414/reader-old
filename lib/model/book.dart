import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

enum BookStatus {
  BOOK_SERIALIZING,
  BOOK_END,
}

@JsonSerializable()
class Book {
  @JsonKey(required: true, disallowNullValue: true, name: 'id')
  String id;

  @JsonKey(required: true, disallowNullValue: true, name: 'name')
  String name;

  @JsonKey(required: true, disallowNullValue: true, name: 'cover')
  String cover;

  @JsonKey(required: true, disallowNullValue: true, name: 'author')
  String author;

  @JsonKey(required: true, disallowNullValue: true, name: 'status')
  BookStatus status;

  @JsonKey(required: true, disallowNullValue: true, name: 'category')
  String category;

  @JsonKey(required: true, disallowNullValue: true, name: 'introduction')
  String introduction;

  @JsonKey(required: true, disallowNullValue: true, name: 'latestChapter')
  String latestChapter;

  Book({this.id, this.name, this.cover, this.author, this.status, this.category, this.introduction, this.latestChapter});

  factory Book.fromJson(Map<String, dynamic> srcJson) => _$BookFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}
