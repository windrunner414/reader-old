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

  static BookChapterList _getChapterList(String data)
    => BookChapterList.fromJson(RuleConfig.parseChapterListResult(data));

  Future<DataResult> getChapterList(String id) {
    return requestAndParse(
      request: () {
        return net.get(RuleConfig.makeChapterListPath(id), cancelToken: cancelToken.net);
      },
      parse: _getChapterList,
    );
  }

  static BookChapterContent _getChapterContent(String data)
    => BookChapterContent.fromJson(RuleConfig.parseChapterContentResult(data));

  Future<DataResult> getChapterContent(String id) {
    return requestAndParse(
      request: () {
        return net.get(RuleConfig.makeChapterContentPath(id), cancelToken: cancelToken.net);
      },
      parse: _getChapterContent,
    );
  }
}
