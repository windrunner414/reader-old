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

  static Future<BookChapterList> _getChapterList(String data) async
    => BookChapterList.fromJson(await RuleConfig.parseChapterListResult(data));

  Future<DataResult> getChapterList(String id) {
    return requestAndParse(
      request: () async {
        return net.get(await RuleConfig.getChapterListPath(id), cancelToken: cancelToken.net);
      },
      parse: _getChapterList,
    );
  }

  static Future<BookChapterContent> _getChapterContent(String data) async
    => BookChapterContent.fromJson(await RuleConfig.parseChapterContentResult(data));

  Future<DataResult> getChapterContent(String id) {
    return requestAndParse(
      request: () async {
        return net.get(await RuleConfig.getChapterContentPath(id), cancelToken: cancelToken.net);
      },
      parse: _getChapterContent,
    );
  }
}
