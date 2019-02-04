import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'package:reader/page/reader/turning/simulation.dart';
import 'package:reader/page/reader/calc_pages.dart';
import 'package:reader/utils/local_storage.dart';
import 'dart:math';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Chapter {
  String title;
  int id;

  Chapter({
    @required this.title,
    @required this.id,
  }) : assert(title != null),
       assert(id != null);
}

typedef getChapterContentCallback = Future<String> Function(int chapterId);
typedef getChapterListCallback = Future<List<Chapter>> Function();

class Reader extends StatefulWidget {
  final int bookId;
  final getChapterContentCallback getChapterContent;
  final getChapterListCallback getChapterList;
  /// will preload preloadNum chapter and cache preloadNum chapter before current chapter
  /// total has preloadNum * 2 + 1 chapter in memory
  final int preloadNum;

  Reader({
    Key key,
    @required this.bookId,
    @required this.getChapterContent,
    @required this.getChapterList,
    this.preloadNum = 5,
  }) : assert(bookId != null),
       assert(getChapterContent != null),
       assert(getChapterList != null),
       assert(preloadNum != null && preloadNum >= 0),
       super(key: key);

  @override
  _ReaderState createState() => _ReaderState();
}

class _ReaderState extends State<Reader> with TickerProviderStateMixin<Reader> {
  int _pageTurningId;
  Color _background;

  bool _inDrag = false, _toPrev = false;
  Offset _beginPoint, _currentPoint, _touchStartPoint;

  Ticker _ticker;
  double _animDistance;
  double _animDistance2; // y distance, only in cancel animation

  Size _size;
  bool _inLoading = false;

  List<Chapter> _chapterList;
  int __currentChapter;
  int __currentPage;

  get _currentPage => __currentPage;

  @protected
  set _currentPage(int page) {
    __currentPage = page;
    _saveReadProgress();
  }

  get _currentChapter => __currentChapter;

  @protected
  set _currentChapter(int chapter) {
    __currentChapter = chapter;
    _saveReadProgress();
  }

  Map<int, List<Picture>> _chapterPages = {};
  int _cacheId = 0;

  void _showLoading() {
    setState(() {
      _inLoading = true;
    });
  }

  void _hideLoading([bool success = true]) {
    setState(() {
      _inLoading = false;
    });
  }

  Future<bool> _saveReadProgress() async {
    return LocalStorage.setStringList('read_progress_${widget.bookId}', ['$_currentChapter', '$_currentPage']);
  }

  void _saveState() async {

  }

  void _restoreState() async {
    _showLoading();
    _pageTurningId = 0;
    _background = Color.fromRGBO(152, 251, 152, 1);

    List<String> progress = await LocalStorage.getStringList('read_progress_${widget.bookId}');
    if (progress?.length == 2) {
      __currentChapter = int.tryParse(progress[0]) ?? 0;
      __currentPage = int.tryParse(progress[1]) ?? 0;
    } else {
      // don't use setter, don't save it
      __currentChapter = 0;
      __currentPage = 0;
    }

    _hideLoading();
  }

  List<Picture> _calcPages(String content) {
    return calcPages(
      content: content,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
      height: 1.1,
      paragraphHeight: 2,
      size: _size,
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
    );
  }

  Future<bool> _getChapterList() async {
    _chapterList = await widget.getChapterList();
    return _chapterList != null;
  }

  Future<void> _getChapterPages() async {
    _showLoading();
    int chapter = _currentChapter;

    if (_chapterList == null) {
      if (!(await _getChapterList())) {
        _hideLoading(false);
        return;
      }
    }

    String content = await widget.getChapterContent(_chapterList[chapter].id);
    if (content == null) {
      _hideLoading(false);
      return;
    }

    _chapterPages[chapter] = _calcPages(content);
    _hideLoading();
  }

  Future<void> _cacheChapters() async {
    int id = ++_cacheId;

    int cacheStart = _currentChapter - widget.preloadNum;
    if (cacheStart < 0) cacheStart = 0;
    int cacheEnd = _currentChapter + widget.preloadNum;
    if (cacheEnd >= _chapterList.length) cacheEnd = _chapterList.length - 1;

    _chapterPages.forEach((int k, List<Picture> v) {
      if (k < cacheStart || k > cacheEnd) {
        _chapterPages.remove(k);
      }
    });

    for (int i = cacheStart; i <= cacheEnd; ++i) {
      if (_chapterPages[i] != null) continue;
      String content = await widget.getChapterContent(_chapterList[i].id);
      if (_cacheId != id) return;
      if (content == null || _chapterPages[i] != null) continue;
      _chapterPages[i] = _calcPages(content);
    }
  }

  List<Picture> _getPages() {
    if (_chapterPages[_currentChapter] == null) {
      _getChapterPages();
      return null;
    }

    _cacheChapters();

    List<Picture> currentChapterPages = _chapterPages[_currentChapter];
    List<Picture> returnPages = [];

    if (_currentPage == -1) {
      _currentPage += currentChapterPages.length;
    }

    if (_currentPage == 0) {
      returnPages.add(_chapterPages[_currentChapter - 1]?.last);
    } else {
      returnPages.add(currentChapterPages[_currentPage - 1]);
    }

    returnPages.add(currentChapterPages[_currentPage]);

    if (currentChapterPages.length - 1 == _currentPage) {
      returnPages.add(_chapterPages[_currentChapter + 1]?.first);
    } else {
      returnPages.add(currentChapterPages[_currentPage + 1]);
    }

    return returnPages;
  }

  PageTurningPainter _getPageTurningPainter() {
    List<Picture> pages = _getPages();
    if (pages == null) return null;

    return SimulationPageTurningPainter(
      beginTouchPoint: _beginPoint,
      touchPoint: _currentPoint,
      prevPage: pages[0],
      currentPage: pages[1],
      nextPage: pages[2],
      background: _background,
      toPrev: _toPrev,
    );
  }

  void _actualToPrev() {
    if (_currentPage == 0) {
      --_currentChapter;
      _currentPage = (_chapterPages[_currentChapter]?.length ?? 0) - 1;
    } else {
      --_currentPage;
    }
  }

  void _toPrevPage() {
    _toPrev = true;
    _animDistance = _size.width - _currentPoint.dx;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _actualToNext() {
    if (_currentPage == _chapterPages[_currentChapter].length - 1) {
      _currentPage = 0;
      ++_currentChapter;
    } else {
      ++_currentPage;
    }
  }

  void _toNextPage() {
    _toPrev = false;
    _animDistance = -_currentPoint.dx;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _cancelToPrevPage() {
    _toPrev = true;
    _animDistance = -_currentPoint.dx - (_size.width - _currentPoint.dx) / 4;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _cancelToNextPage() {
    _toPrev = false;
    _animDistance = _size.width - _currentPoint.dx + 1; // don't be zero
    _animDistance2 = 0;
    if (_currentPoint.dy < _size.height / 3) {
      _animDistance2 = -_currentPoint.dy;
    } else if (_currentPoint.dy >= _size.height * 2 / 3) {
      _animDistance2 = _size.height - _currentPoint.dy;
    }
    _ticker.start();
  }

  void _onTick(Duration duration) {
    int animDurationMs = 200;
    if (duration.inMilliseconds >= animDurationMs || _animDistance == 0) {
      _ticker.stop();
      setState(() {
        _inDrag = false;
        _beginPoint = _currentPoint = _touchStartPoint = null;
        if (!_toPrev && _animDistance <= 0) {
          _actualToNext();
        } else if (_toPrev && _animDistance >= 0) {
          _actualToPrev();
        }
      });
      return;
    }

    double p = duration.inMilliseconds / animDurationMs;
    setState(() {
      _currentPoint = Offset(
        _currentPoint.dx + _animDistance * p,
        _currentPoint.dy + _animDistance2 * p,
      );
    });
  }

  bool _canTurningPage() {
    if (_toPrev) {
      return _currentChapter > 0 || _currentPage > 0;
    } else {
      return _currentChapter < _chapterList.length - 1
          || _currentPage < _chapterPages[_currentChapter].length - 1;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_touchStartPoint == null) return;

    if (_inDrag) {
      _currentPoint = details.globalPosition;
    } else {
      double dx = details.globalPosition.dx - _touchStartPoint.dx;
      double dy = details.globalPosition.dy - _touchStartPoint.dy;
      double distance = sqrt(dx * dx + dy * dy);

      if (distance > 10) {
        if (dx <= 0) {
          _toPrev = false;
        } else {
          _toPrev = true;
        }

        if (!_canTurningPage()) {
          _touchStartPoint = null;
          return;
        }

        _inDrag = true;
        _beginPoint = details.globalPosition;
      }
    }

    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_touchStartPoint == null) {
      if (_toPrev) {
        Fluttertoast.showToast(msg: '没有上一章了');
      } else {
        Fluttertoast.showToast(msg: '没有下一章了');
      }

      return;
    }

    if (_currentPoint == null) {
      // on click
      double dx = _touchStartPoint.dx;
      if (dx < _size.width / 3) {
        _toPrev = true;
        if (!_canTurningPage()) {
          _touchStartPoint = null;
          _onPanEnd(null);
          return;
        }
        _currentPoint = _beginPoint = _touchStartPoint;
        _inDrag = true;
        _toPrevPage();
      } else if (dx >= _size.width / 3 && dx < _size.width * 2 / 3) {
        // display other widgets
      } else {
        _toPrev = false;
        if (!_canTurningPage()) {
          _touchStartPoint = null;
          _onPanEnd(null);
          return;
        }
        _currentPoint = _beginPoint = _touchStartPoint;
        _inDrag = true;
        _toNextPage();
      }

      return;
    }

    double dx = _currentPoint.dx;
    if (_toPrev) {
      if (dx - _beginPoint.dx > 25) {
        _toPrevPage();
      } else {
        _cancelToPrevPage();
      }
    } else {
      if (_beginPoint.dx - dx > 25) {
        _toNextPage();
      } else {
        _cancelToNextPage();
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_ticker.isActive) {
      _onTick(Duration(milliseconds: 300)); // stop
    }

    _touchStartPoint = details.globalPosition;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _ticker = createTicker(_onTick);
    _restoreState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Size size = MediaQuery.of(context).size;
    _size = size;
    PageTurningPainter painter;

    if (size == Size.zero
        || _background == null
        || (painter = _getPageTurningPainter()) == null) {
      children.add(Container(
        color: _background,
      ));
    } else {
      children.add(RepaintBoundary(
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanStart: _onPanStart,
          child: CustomPaint(
            size: size,
            isComplex: true,
            willChange: _inDrag,
            painter: painter,
          ),
        ),
      ));
    }

    if (_inLoading) {
      children.add(Container(
        color: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(5)
              ),
              child: SpinKitFadingCircle(
                color: Colors.white70,
                size: 40,
              ),
            ),
          ),
        ),
      ));
    }

    return Stack(
      children: children,
    );
  }
}