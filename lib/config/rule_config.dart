import 'package:reader/utils/chs_cht_converter.dart';

class RuleConfig {
  /// 根据id构造章节列表页的路径
  static String makeChapterListPath(String id) {
    return '/book/$id/';
  }

  /// 解析章节列表页返回结果，转换为Map，符合model.fromJson的格式
  static Map<String, dynamic> parseChapterListResult(String body) {
    String regExp = '<a href="/book/(.+?)\\.html" class="ui_catalog"><span class="title">(.+?)</span>';
    Iterable<Match> matches = RegExp(regExp).allMatches(body);
    if (matches == null) throw Error();
    Map<String, List> result = {'chapterList': []};
    for (Match match in matches) {
      result['chapterList'].add({'title': CHSCHTConverter.t2s(match.group(2)), 'id': match.group(1).replaceFirst('/', '_')});
    }
    return result;
  }

  /// 根据id构造章节内容页路径
  static String makeChapterContentPath(String id) {
    return '/book/${id.replaceFirst('_', '/')}.html';
  }

  /// 解析章节内容页返回结果
  static Map<String, dynamic> parseChapterContentResult(String body) {
    String regExp = '<div class="r-content" id="uiContent">([\\s\\S]+?)</div>';
    Match match = RegExp(regExp).firstMatch(body);
    if (match == null) throw Error();
    return {'content': CHSCHTConverter.t2s(match.group(1).trim().replaceAll(RegExp('(<br/>)+'), '\n').replaceAll('&nbsp;', ' '))};
  }
}
