import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:reader/model/reading_progress.dart';

export 'package:reader/model/book_chapter_list.dart';
export 'package:reader/model/book_chapter_content.dart';
export 'package:reader/model/reading_progress.dart';

abstract class BookDataSource {
  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  });

  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  });

  Future<ReadingProgress> getReadingProgress(String bookId);

  Future<void> saveReadingProgress(ReadingProgress readingProgress);
}
