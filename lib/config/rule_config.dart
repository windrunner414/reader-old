class RuleConfig {
  /// 根据id构造章节列表页的路径
  static Future<String> getChapterListPath(String bookId) async {
    return '/$bookId/';
  }

  /// 解析章节列表页返回结果，转换为Map，符合model.fromJson的格式
  static Future<Map<String, dynamic>> parseChapterListResult(String body) async {
    String regExp = '<a title=".+?" href="/.+?/read_(\\d+)\\.html" class="compulsory-row-one none">(.+?)</a>';
    Iterable<Match> matches = RegExp(regExp).allMatches(body);
    if (matches == null) throw Error();
    Map<String, List> result = {'chapterList': []};
    for (Match match in matches) {
      result['chapterList'].add({'title': match.group(2), 'id': match.group(1)});
    }
    return result;
  }

  /// 根据id构造章节内容页路径
  static Future<String> getChapterContentPath(String bookId, String chapterId) async {
    return '/$bookId/read_$chapterId.html';
  }

  /// 解析章节内容页返回结果
  static Future<Map<String, dynamic>> parseChapterContentResult(String body) async {
    String regExp = '<div class="size18 color5 pt-read-text">([\\s\\S]+?)</div>';
    Match match = RegExp(regExp).firstMatch(body);
    if (match == null) throw Error();
    return {'content': match.group(1).trim().replaceAll('</p>', '\n').replaceAll('<p>', '')};
  }
}
