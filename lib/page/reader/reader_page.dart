import 'package:flutter/material.dart';
import 'package:reader/widget/task_cancel_token_provider.dart';
import 'package:reader/page/reader/reader.dart';
import 'package:reader/di/di.dart';
import 'package:reader/repository/book_repository.dart';

class ReaderPage extends StatefulWidget {
  final String bookId;
  final String bookName;
  ReaderPage({Key key, @required this.bookId, @required this.bookName}) : super(key: key);

  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> with TaskCancelTokenProviderStateMixin<ReaderPage> {
  BookRepository _bookRepository = inject<BookRepository>();

  @override
  void initState() {
    super.initState();
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
      getChapterContent: (String bookId, String id) async {
        try {
          return (await _bookRepository.getChapterContent(bookId: bookId, chapterId: id, source: 'zhuidu')).content;
        } catch (_) {
          return null;
        }
      },
      getChapterList: (String id) async {
        try {
          return (await _bookRepository.getChapterList(bookId: id, source: 'zhuidu')).chapterList;
        } catch (e, s) {
          print(e);
          print(s);
          return null;
        }
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
