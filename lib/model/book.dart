import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

enum BookStatus {
  BOOK_SERIALIZING,
  BOOK_END,
}

@JsonSerializable()
class Book {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'status')
  BookStatus status;

  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'introduction')
  String introduction;

  @JsonKey(name: 'latestChapter')
  String latestChapter;

  Book({this.id, this.name, this.cover, this.author, this.status, this.category, this.introduction, this.latestChapter});

  factory Book.fromJson(Map<String, dynamic> srcJson) => _$BookFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}
