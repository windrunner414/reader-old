import 'data_source/book_data_source.dart';
import 'package:reader/model/reading_progress.dart';

abstract class BookRepository {
  Future<ReadingProgress> getReadingProgress(String bookId);

  Future<void> saveReadingProgress(ReadingProgress readingProgress);

  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  });

  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  });
}
