import 'package:reader/utils/net.dart';
import 'package:reader/dao/base_dao.dart';
import 'package:reader/config.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:reader/utils/anonymous_task.dart';

class BookDao extends BaseDao {
  BookDao({CancelToken cancelToken}) : super(cancelToken: cancelToken);

  Future<DataResult> getBookInfo(String id) async {
    return null;
  }

  static Future<DataResult> _getChapterList(String id) async {
    String path = Config.rule.makeChapterListPath(id);
    Response response = await net.get(path);
    var result = Config.rule.parseChapterListResult(response.data);
    return DataResult(data: BookChapterList.fromJson(result), success: true);
  }

  Future<DataResult> getChapterList(String id) async {
    return performNetTask(AnonymousTask(_getChapterList, positionalArguments: [id]));
  }

  static Future<DataResult> _getChapterContent(String id) async {
    String path = Config.rule.makeChapterContentPath(id);
    Response response = await net.get(path);
    var result = Config.rule.parseChapterContentResult(response.data);
    return DataResult(data: BookChapterContent.fromJson(result), success: true);
  }

  Future<DataResult> getChapterContent(String id) async {
    return performNetTask(AnonymousTask(_getChapterContent, positionalArguments: [id]));
  }
}