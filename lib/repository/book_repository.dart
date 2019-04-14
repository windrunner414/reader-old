import 'data_source/book_data_source.dart';
import 'package:reader/model/reading_progress.dart';
import 'package:meta/meta.dart';

abstract class BookRepository {
  Future<ReadingProgress> getReadingProgress(String bookId);

  Future<void> saveReadingProgress(ReadingProgress readingProgress);

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
