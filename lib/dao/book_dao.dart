import 'package:reader/utils/net.dart';
import 'package:reader/config.dart';
import 'package:reader/dao/data_result.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';

class BookDao {
  static Future<DataResult> getChapterList(String id) async {
    try {
      String path = Config.rule.makeChapterListPath(id);
      Response response = await net.get(path);
      var result = Config.rule.parseChapterListResult(response.data);
      return DataResult(data: BookChapterList.fromJson(result), success: true);
    } catch (_) {
      return DataResult(success: false, errMsg: '加载失败');
    }
  }

  static Future<DataResult> getChapterContent(String id) async {
    try {
      String path = Config.rule.makeChapterContentPath(id);
      Response response = await net.get(path);
      var result = Config.rule.parseChapterContentResult(response.data);
      return DataResult(data: BookChapterContent.fromJson(result), success: true);
    } catch (_) {
      return DataResult(success: false, errMsg: '加载失败');
    }
  }
}