import 'package:dio/dio.dart';
import 'package:reader/utils/chs_cht_converter.dart';

class Config {
  static int taskWorkerNum = 5; /// 工作isolate数，用于解析api返回内容等
  static int downloadConcurrencyNum = 5; /// 缓存小说的并发请求数

  static BaseOptions netOptions = BaseOptions(
    connectTimeout: 5000, /// 连接超时时间，单位毫秒
    receiveTimeout: 8000, /// 接收数据超时时间，单位毫秒
    baseUrl: 'https://m.cread.tw', /// api基础url，实际请求url为基础url + 路径
    responseType: ResponseType.plain, /// api返回数据类型，设置为plain不要改动
  );

  static Rule rule = Rule(
    /// 根据id构造章节列表页的路径
    makeChapterListPath: (String id) => '/book/$id/',
    /// 解析章节列表页返回结果，转换为Map，符合model.fromJson的格式
    parseChapterListResult: (String body) {
      String regExp = '<a href="(.+?)" class="ui_catalog"><span class="title">(.+?)</span>';
      Iterable<Match> matches = RegExp(regExp).allMatches(body);
      if (matches == null) throw Error();
      Map<String, List> result = {'chapterList': []};
      for (Match match in matches) {
        result['chapterList'].add({'title': CHSCHTConverter.t2s(match.group(2)), 'id': match.group(1)});
      }
      return result;
    },
    /// 根据id构造章节内容页路径
    makeChapterContentPath: (String id) => id,
    /// 解析章节内容页返回结果
    parseChapterContentResult: (String body) {
      String regExp = '<div class="r-content" id="uiContent">([\\s\\S]+?)</div>';
      Match match = RegExp(regExp).firstMatch(body);
      if (match == null) throw Error();
      return {'content': CHSCHTConverter.t2s(match.group(1).trim().replaceAll(RegExp('(<br/>)+'), '\n').replaceAll('&nbsp;', ' '))};
    }
  );
}

typedef MakePathByIDFunction = String Function(String);
typedef ParseResultFunction = Map<String, dynamic> Function(String);

class Rule {
  final MakePathByIDFunction makeChapterListPath;
  final ParseResultFunction parseChapterListResult;
  final MakePathByIDFunction makeChapterContentPath;
  final ParseResultFunction parseChapterContentResult;

  const Rule({
    this.makeChapterListPath,
    this.parseChapterListResult,
    this.makeChapterContentPath,
    this.parseChapterContentResult,
  }) : assert(makeChapterListPath != null),
    assert(parseChapterListResult != null),
    assert(makeChapterContentPath != null),
    assert(parseChapterContentResult != null);
}
