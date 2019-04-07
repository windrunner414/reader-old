import 'package:reader/utils/net.dart';
import 'package:reader/dao/base_dao.dart';
import 'package:reader/config.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';

class BookDao extends BaseDao {
  BookDao({CancelToken cancelToken}) : super(cancelToken: cancelToken);

  Future<DataResult> getBookInfo(String id) {
    return null;
  }

  static BookChapterList _getChapterList(String data)
    => BookChapterList.fromJson(Config.rule.parseChapterListResult(data));

  Future<DataResult> getChapterList(String id) {
    return requestAndParse(
      request: () {
        return net.get(Config.rule.makeChapterListPath(id), cancelToken: cancelToken);
      },
      parse: _getChapterList,
    );
  }

  static BookChapterContent _getChapterContent(String data)
    => BookChapterContent.fromJson(Config.rule.parseChapterContentResult(data));

  Future<DataResult> getChapterContent(String id) {
    return requestAndParse(
      request: () {
        return net.get(Config.rule.makeChapterContentPath(id), cancelToken: cancelToken);
      },
      parse: _getChapterContent,
    );
  }
}