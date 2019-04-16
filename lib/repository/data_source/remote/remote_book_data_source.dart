import '../book_data_source.dart';
import 'api/book_api.dart';
import 'package:reader/di/di.dart';

class RemoteBookDataSource implements BookDataSource {
  final BookApi _bookApi = inject<BookApi>();

  @override
  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  }) => _bookApi.getChapterList(bookId: bookId, source: source);

  @override
  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  }) => _bookApi.getChapterContent(bookId: bookId, chapterId: chapterId, source: source);

  @override
  Future<ReadingProgress> getReadingProgress(String bookId) {
    throw Exception('not implemented');
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress readingProgress) {
    throw Exception('not implemented');
  }
}
