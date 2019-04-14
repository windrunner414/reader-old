import 'package:reader/utils/http_util.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';

part 'zhuidu_rule.dart';

/// 若规则需要热更新，可以使用其他办法实现（比如使用lua脚本）
/// 该接口只在api_config中使用，其他地方均为调用api_config内方法，可以自行修改规则的实现
abstract class Rule {
  /// 构造章节列表页请求
  Future<HttpRequest> makeChapterListRequest({String bookId});

  /// 解析章节列表页响应
  Future<BookChapterList> parseChapterListResponse({String response, String bookId});

  /// 构造章节内容页请求
  Future<HttpRequest> makeChapterContentRequest({String bookId, String chapterId});

  /// 解析章节内容页响应
  Future<BookChapterContent> parseChapterContentResponse({String response, String bookId, String chapterId});
}
