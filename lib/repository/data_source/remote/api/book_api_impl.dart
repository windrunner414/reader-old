import 'book_api.dart';
import 'package:reader/model/book.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:reader/utils/http_util.dart';
import 'package:reader/utils/worker_util.dart';
import 'package:reader/config/api/book_api_config.dart';

class BookApiImpl implements BookApi {
  @override
  Future<BookChapterList> getChapterList({
    String bookId,
    String source,
  }) async {
    HttpRequest request = await BookApiConfig.makeChapterListRequest(
      bookId: bookId,
      source: source,
    );
    Response response = await HttpUtil.request(request);
    return await WorkerUtil.run<BookChapterList>(
      BookApiConfig.parseChapterListResponse,
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
    HttpRequest request = await BookApiConfig.makeChapterContentRequest(
      bookId: bookId,
      chapterId: chapterId,
      source: source,
    );
    Response response = await HttpUtil.request(request);
    return await WorkerUtil.run<BookChapterContent>(
      BookApiConfig.parseChapterContentResponse,
      namedArguments: {
        #response: response.data as String,
        #bookId: bookId,
        #chapterId: chapterId,
        #source: source,
      },
    );
  }
}
