part of 'rule.dart';

class ZhuiDuRule implements Rule {
  Future<HttpRequest> makeChapterListRequest({String bookId}) async {
    return HttpRequest(path: '/$bookId/');
  }

  Future<BookChapterList> parseChapterListResponse({String response, String bookId}) async {
    String regExp = '<a title=".+?" href="/.+?/read_(\\d+)\\.html" class="compulsory-row-one none">(.+?)</a>';
    Iterable<Match> matches = RegExp(regExp).allMatches(response);
    if (matches == null) throw Error();
    BookChapterList result = BookChapterList(chapterList: []);
    for (Match match in matches) {
      result.chapterList.add(BookChapterInfo(title: match.group(2), id: match.group(1)));
    }
    return result;
  }

  Future<HttpRequest> makeChapterContentRequest({String bookId, String chapterId}) async {
    return HttpRequest(path: '/$bookId/read_$chapterId.html');
  }

  Future<BookChapterContent> parseChapterContentResponse({String response, String bookId, String chapterId}) async {
    String regExp = '<div class="size18 color5 pt-read-text">([\\s\\S]+?)</div>';
    Match match = RegExp(regExp).firstMatch(response);
    if (match == null) throw Error();
    return BookChapterContent(content: match.group(1).trim().replaceAll('</p>', '\n').replaceAll('<p>', ''));
  }
}
