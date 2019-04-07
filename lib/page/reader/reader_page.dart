import 'package:flutter/material.dart';
import 'package:reader/page/state_with_net_manager.dart';
import 'package:reader/page/reader/reader.dart';
import 'package:reader/dao/book_dao.dart';
import 'package:reader/dao/data_result.dart';

class ReaderPage extends StatefulWidget {
  final String bookId;
  final String bookName;
  ReaderPage({Key key, @required this.bookId, @required this.bookName}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends StateWithNetManager<ReaderPage> {
  BookDao _bookDao;

  @override
  void initState() {
    super.initState();
    _bookDao = BookDao(cancelToken: cancelToken);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Reader(
      bookId: widget.bookId,
      bookName: widget.bookName,
      download: (String id, List<String> chapterId) {

      },
      getChapterContent: (String id) async {
        DataResult result = await _bookDao.getChapterContent(id);
        if (result.status != DataResultStatus.SUCCESS) return null;
        return result.data.content;
      },
      getChapterList: (String id) async {
        DataResult result = await _bookDao.getChapterList(id);
        if (result.status != DataResultStatus.SUCCESS) return null;
        return result.data.chapterList;
      },
      isCached: (String id) {
        if (id == '1') return true;
        return false;
      },
      onWillPop: () {
        print('pop');
        return Future.value(true);
      },
    );
  }
}
