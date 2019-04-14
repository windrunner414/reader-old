import 'rule/rule.dart';
import 'package:reader/utils/http_util.dart';
import 'package:reader/model/book_chapter_list.dart';
import 'package:reader/model/book_chapter_content.dart';
import 'package:meta/meta.dart';

/// API配置
/// 所有parse方法均会在isolate（taskWorker）中执行，防止阻塞UI线程
/// isolate存在一些限制，比如不能使用method channel（无法调用原生方法，插件无法使用）
/// 传递给isolate的数据也有限制，比如无法传递闭包
class ApiConfig {
  ApiConfig._();

  /// 根据源来选择规则
  static Rule _getRuleBySource(String source) {
    switch (source) {
      case 'zhuidu':
        return ZhuiDuRule();
      default:
        throw Exception('source $source does not exist');
    }
  }

  /// 构造源列表请求
  static Future<HttpRequest> makeSourceListRequest({@required String bookId}) async {

  }

  /// 解析源列表响应
  /// 若未使用支持热更新的规则方案，建议在此过滤掉不支持的规则
  static Future<List<String>> parseSourceListResponse({
    @required String response,
    @required String bookId,
  }) async {

  }

  /// 构造章节列表页请求
  static Future<HttpRequest> makeChapterListRequest({
    @required String bookId,
    @required String source,
  }) => _getRuleBySource(source).makeChapterListRequest(bookId: bookId);

  /// 解析章节列表页响应
  static Future<BookChapterList> parseChapterListResponse({
    @required String response,
    @required String bookId,
    @required String source,
  }) => _getRuleBySource(source).parseChapterListResponse(
    response: response,
    bookId: bookId,
  );

  /// 构造章节内容页请求
  static Future<HttpRequest> makeChapterContentRequest({
    @required String bookId,
    @required String chapterId,
    @required String source,
  }) => _getRuleBySource(source).makeChapterContentRequest(
    bookId: bookId,
    chapterId: chapterId,
  );

  /// 解析章节内容页响应
  static Future<BookChapterContent> parseChapterContentResponse({
    @required String response,
    @required String bookId,
    @required String chapterId,
    @required String source,
  }) => _getRuleBySource(source).parseChapterContentResponse(
    response: response,
    bookId: bookId,
    chapterId: chapterId,
  );
}
