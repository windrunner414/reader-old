import 'package:reader/model/book.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:meta/meta.dart';

abstract class BookApi {
  Future<BookChapterList> getChapterList({
    @required String bookId,
    @required String source,
  });

  Future<BookChapterContent> getChapterContent({
    @required String bookId,
    @required String chapterId,
    @required String source,
  });
}
