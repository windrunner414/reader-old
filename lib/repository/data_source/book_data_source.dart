import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:reader/model/reading_progress.dart';
import 'package:meta/meta.dart';

export 'package:reader/model/book_chapter_list.dart';
export 'package:reader/model/book_chapter_content.dart';
export 'package:reader/model/reading_progress.dart';

abstract class BookDataSource {
  Future<BookChapterList> getChapterList({
    @required String bookId,
    @required String source,
  });

  Future<BookChapterContent> getChapterContent({
    @required String bookId,
    @required String chapterId,
    @required String source,
  });

  Future<ReadingProgress> getReadingProgress(String bookId);

  Future<void> saveReadingProgress(ReadingProgress readingProgress);
}
