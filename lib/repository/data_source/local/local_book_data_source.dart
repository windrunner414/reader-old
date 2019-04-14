import '../book_data_source.dart';
import 'dao/reading_progress_dao.dart';
import 'package:reader/di/di.dart';

class LocalBookDataSource implements BookDataSource {
  final ReadingProgressDao _readingProgressDao = inject<ReadingProgressDao>();

  @override
  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  }) {

  }

  @override
  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  }) {

  }

  @override
  Future<ReadingProgress> getReadingProgress(String bookId) {
    return _readingProgressDao.findByBookId(bookId);
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress readingProgress) {
    return _readingProgressDao.save(readingProgress);
  }
}
