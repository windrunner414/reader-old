import 'package:reader/utils/net.dart';
import 'package:reader/dao/base_dao.dart';
import 'package:reader/config/rule_config.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:reader/utils/task_cancel_token.dart';

class BookDao extends BaseDao {
  BookDao({TaskCancelToken cancelToken}) : super(cancelToken: cancelToken);

  Future<DataResult> getBookInfo(String id) {
    return null;
  }

  static Future<BookChapterList> _parseChapterList(String data) async
    => BookChapterList.fromJson(await RuleConfig.parseChapterListResult(data));

  Future<DataResult> getChapterList(String bookId) {
    return requestAndParse(
      request: () async {
        return net.get(await RuleConfig.getChapterListPath(bookId), cancelToken: cancelToken.net);
      },
      parse: _parseChapterList,
    );
  }

  static Future<BookChapterContent> _parseChapterContent(String data) async
    => BookChapterContent.fromJson(await RuleConfig.parseChapterContentResult(data));

  Future<DataResult> getChapterContent(String bookId, String chapterId) {
    return requestAndParse(
      request: () async {
        return net.get(await RuleConfig.getChapterContentPath(bookId, chapterId), cancelToken: cancelToken.net);
      },
      parse: _parseChapterContent,
    );
  }
}
