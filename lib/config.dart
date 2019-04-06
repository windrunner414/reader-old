import 'package:dio/dio.dart';
import 'package:reader/utils/chs_cht_converter.dart';

class Config {
  static int netIsolateNum = 6; // net thread num, max number of concurrent requests
  static int downloadConcurrencyNum = 5; // should be less than netIsolateNum

  static BaseOptions netOptions = BaseOptions(
    connectTimeout: 5000,
    receiveTimeout: 8000,
    baseUrl: 'https://m.cread.tw',
    responseType: ResponseType.plain,
  );

  static Rule rule = Rule(
    makeChapterListPath: (String id) => '/book/$id/',
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
    makeChapterContentPath: (String id) => id,
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
