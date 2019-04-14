import 'book_repository.dart';
import 'data_source/book_data_source.dart';
import 'package:reader/di/di.dart';

class BookRepositoryImpl implements BookRepository {
  final BookDataSource _remoteBookDataSource = inject<BookDataSource>(scope: remote);

  final BookDataSource _localBookDataSource = inject<BookDataSource>(scope: local);

  Future<ReadingProgress> getReadingProgress(String bookId) {
    return _localBookDataSource.getReadingProgress(bookId);
  }

  Future<void> saveReadingProgress(ReadingProgress readingProgress) {
    return _localBookDataSource.saveReadingProgress(readingProgress);
  }

  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  }) {
    return _remoteBookDataSource.getChapterList(
      bookId: bookId,
      source: source,
    );
  }

  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  }) {
    return _remoteBookDataSource.getChapterContent(
      bookId: bookId,
      chapterId: chapterId,
      source: source,
    );
  }
}
