import '../book_data_source.dart';
import 'package:reader/utils/http_util.dart';
import 'package:reader/utils/worker_util.dart';
import 'package:reader/config/api_config.dart';

class RemoteBookDataSource implements BookDataSource {
  @override
  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  }) async {
    HttpRequest request = await ApiConfig.makeChapterListRequest(
      bookId: bookId,
      source: source,
    );
    Response response = await HttpUtil.request(request);
    return await WorkerUtil.run(
      ApiConfig.parseChapterListResponse,
      namedArguments: {
       #response: response.data as String,
       #bookId: bookId,
       #source: source,
      },
    );
  }

  @override
  Future<BookChapterContent> getChapterContent({
    String bookId,
    String chapterId,
    String source,
  }) async {
    HttpRequest request = await ApiConfig.makeChapterContentRequest(
      bookId: bookId,
      chapterId: chapterId,
      source: source,
    );
    Response response = await HttpUtil.request(request);
    return await WorkerUtil.run(
      ApiConfig.parseChapterContentResponse,
      namedArguments: {
        #response: response.data as String,
        #bookId: bookId,
        #chapterId: chapterId,
        #source: source,
      },
    );
  }

  @override
  Future<ReadingProgress> getReadingProgress(String bookId) {

  }

  @override
  Future<void> saveReadingProgress(ReadingProgress readingProgress) {

  }
}
