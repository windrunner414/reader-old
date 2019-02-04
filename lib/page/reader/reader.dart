import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'package:reader/page/reader/turning/simulation.dart';
import 'package:reader/page/reader/calc_pages.dart';
import 'package:reader/utils/local_storage.dart';
import 'package:reader/utils/time.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:battery/battery.dart';

class Chapter {
  String title;
  int id;

  Chapter({
    @required this.title,
    @required this.id,
  }) : assert(title != null),
       assert(id != null);
}

class ReaderPreferences {
  int pageTurning;
  Color background;
  Color fontColor;
  double fontSize;
  FontWeight fontWeight;
  double height;
  int paragraphHeight;
  bool fullScreen;

  static final ReaderPreferences defaultPref = ReaderPreferences(
    pageTurning: 0,
    background: Color.fromRGBO(213, 239, 210, 1),
    fontColor: Colors.black87,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    height: 1.15,
    paragraphHeight: 1,
    fullScreen: true,
  );

  ReaderPreferences({
    this.pageTurning,
    this.background,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.paragraphHeight,
    this.fullScreen,
  });

  Map<String, dynamic> toJson() {
    return {
      'pageTurning': pageTurning,
      'background': background,
      'fontColor': fontColor,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'height': height,
      'paragraphHeight': paragraphHeight,
      'fullScreen': fullScreen,
    };
  }

  ReaderPreferences.fromJson(Map<String, dynamic> json) :
    pageTurning = json['pageTurning'],
    background = json['background'],
    fontColor = json['fontColor'],
    fontSize = json['fontSize'],
    fontWeight = json['fontWeight'],
    height = json['height'],
    paragraphHeight = json['paragraphHeight'],
    fullScreen = json['fullScreen'];
}

typedef getChapterContentCallback = Future<String> Function(int chapterId);
typedef getChapterListCallback = Future<List<Chapter>> Function();

class Reader extends StatefulWidget {
  final int bookId;
  final getChapterContentCallback getChapterContent;
  final getChapterListCallback getChapterList;
  final int preloadNum;

  Reader({
    Key key,
    @required this.bookId,
    @required this.getChapterContent,
    @required this.getChapterList,
    this.preloadNum = 1,
  }) : assert(bookId != null),
       assert(getChapterContent != null),
       assert(getChapterList != null),
       assert(preloadNum != null && preloadNum >= 0),
       super(key: key);

  @override
  _ReaderState createState() => _ReaderState();
}

class _ReaderState extends State<Reader> with TickerProviderStateMixin<Reader> {
  ReaderPreferences _preferences;
  ReaderPreferences get preferences => _preferences;

  bool _inDrag = false, _toPrev = false;
  Offset _beginPoint, _currentPoint, _touchStartPoint;

  Ticker _ticker;
  double _animDistance;
  double _animDistance2; // y distance, only in cancel animation

  Size _size;
  bool _inLoading = false;
  bool _loadError = false;

  Map<int, Chapter> _chapterList;
  int __currentChapter;
  int __currentPage;

  int get _currentPage => __currentPage;

  @protected
  set _currentPage(int page) {
    __currentPage = page;
    _saveReadProgress();
  }

  int get _currentChapter => __currentChapter;

  @protected
  set _currentChapter(int chapter) {
    __currentChapter = chapter;
    _saveReadProgress();
  }

  Map<int, List<Picture>> _chapterPages = {};
  Map<int, String> _chapterContents = {};
  int _cacheId = -1;

  EdgeInsets get _safeArea {
    return (_preferences?.fullScreen ?? false)
      ? EdgeInsets.zero
      : MediaQueryData.fromWindow(window).padding;
  }
  int _batteryLevel = 100;
  DateTime _now;

  void _showLoading() {
    setState(() {
      _inLoading = true;
    });
  }

  void _hideLoading([bool success = true]) {
    setState(() {
      if (!success) {
        Fluttertoast.showToast(msg: '加载失败');
        _loadError = true;
      }
      _inLoading = false;
    });
  }

  Future<bool> _saveReadProgress() async {
    return LocalStorage.setStringList('read_progress_${widget.bookId}', ['$_currentChapter', '$_currentPage']);
  }

  Future<void> setPreferences(ReaderPreferences pref) async {
    if (_preferences == null) {
      _preferences = ReaderPreferences.defaultPref;
    }

    if (pref != null) {
      var prefJson = pref.toJson();
      var currPrefJson = _preferences.toJson();
      prefJson.forEach((String k, v) {
        if (v != null) currPrefJson[k] = v;
      });
      _preferences = ReaderPreferences.fromJson(currPrefJson);
      await LocalStorage.setString('reader_preferences', json.encode(_preferences));
    }

    if (_preferences.fullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }

    setState(() => _reCalcPages());
  }

  Future<void> _restoreState() async {
    _showLoading();

    List<String> progress = await LocalStorage.getStringList('read_progress_${widget.bookId}');
    if (progress?.length == 2) {
      __currentChapter = int.tryParse(progress[0]) ?? 0;
      __currentPage = int.tryParse(progress[1]) ?? 0;
    } else {
      // don't use setter, don't save it
      __currentChapter = 0;
      __currentPage = 0;
    }

    // must set it at end, used to know whether restoreState is complete
    try {
      String readerPref = await LocalStorage.getString('reader_preferences');
      setPreferences(ReaderPreferences.fromJson(json.decode(readerPref)));
    } catch(_) {
      setPreferences(null);
    }

    _hideLoading();
  }

  void _reCalcPages() {
    _chapterContents.forEach((int k, String v) {
      _chapterPages[k] = _calcPages(v);
    });
  }

  List<Picture> _calcPages(String content) {
    return calcPages(
      content: content,
      fontSize: _preferences.fontSize,
      fontWeight: _preferences.fontWeight,
      color: _preferences.fontColor,
      height: _preferences.height,
      paragraphHeight: _preferences.paragraphHeight,
      size: _size,
      padding: (const EdgeInsets.fromLTRB(15, 30, 15, 30)).add(_safeArea),
    );
  }

  Future<void> _getChapterList() async {
    Map<int, Chapter> chapterList = (await widget.getChapterList())?.asMap();
    if (chapterList != null && chapterList.length > 0) {
      _chapterList = chapterList;
    }

    if (_chapterList != null) {
      Future.delayed(Duration(minutes: 5))
        .then((_) => _getChapterList());
    }
  }

  Future<void> _getChapterPages() async {
    _showLoading();
    if (_chapterList == null) {
      await _getChapterList();
      if (_chapterList == null) {
        _hideLoading(false);
        return;
      }
    }

    if (_chapterList[_currentChapter] == null) {
      _currentChapter = 0;
    }

    String content = await widget.getChapterContent(_chapterList[_currentChapter].id);
    if (content == null || content.isEmpty) {
      _hideLoading(false);
      return;
    }

    _chapterContents[_currentChapter] = content;
    _chapterPages[_currentChapter] = _calcPages(content);
    _hideLoading();
  }

  Future<void> _cacheChapters() async {
    if (_cacheId == _currentChapter) {
      return;
    }

    int id = _cacheId = _currentChapter;

    int cacheStart = _currentChapter - widget.preloadNum;
    if (cacheStart < 0) cacheStart = 0;
    int cacheEnd = _currentChapter + widget.preloadNum;
    if (cacheEnd >= _chapterList.length) cacheEnd = _chapterList.length - 1;

    _chapterPages.forEach((int k, List<Picture> v) {
      if (k < cacheStart || k > cacheEnd) {
        _chapterContents.remove(k);
        _chapterPages.remove(k);
      }
    });

    for (int i = cacheStart; i <= cacheEnd; ++i) {
      if (_chapterPages[i] != null) continue;
      String content = await widget.getChapterContent(_chapterList[i].id);
      if (_cacheId != id) return;
      if (content == null || content.isEmpty || _chapterPages[i] != null) continue;
      _chapterContents[i] = content;
      _chapterPages[i] = _calcPages(content);
    }
  }

  List<Picture> _getPages() {
    if (!_loadError) {
      if (_chapterPages[_currentChapter] == null) {
        _getChapterPages();
        return null;
      }
    }

    _cacheChapters();

    List<Picture> currentChapterPages = _chapterPages[_currentChapter] ?? [null];
    List<Picture> returnPages = [];

    if (_currentPage == -1) {
      _currentPage += currentChapterPages.length;
    }

    if (_currentPage < 0 || _currentPage >= currentChapterPages.length) {
      _currentPage = 0;
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
      background: _preferences.background,
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
    _loadError = false;
  }

  void _toPrevPage() {
    _toPrev = true;
    _animDistance = _size.width - _currentPoint.dx;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _actualToNext() {
    if (_currentPage == (_chapterPages[_currentChapter]?.length ?? 1) - 1) {
      _currentPage = 0;
      ++_currentChapter;
    } else {
      ++_currentPage;
    }
    _loadError = false;
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

  void _minuteTimer() async {
    while (true) {
      _batteryLevel = await Battery().batteryLevel;
      _now = DateTime.now();
      setState(() {});

      int ms = 1000 - _now.millisecond;
      await Future.delayed(Duration(milliseconds: ms));
    }
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = createTicker(_onTick);
    _restoreState();
    _minuteTimer();
  }

  @override
  void dispose() {
    super.dispose();
    if (_preferences.fullScreen) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }

  Widget _reloadWidget() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 30,
        child: RawMaterialButton(
          child: Text('重新加载'),
          elevation: 0,
          highlightElevation: 0,
          fillColor: Color.fromRGBO(30, 140, 255, 1),
          highlightColor: Color.fromRGBO(20, 120, 255, 1),
          splashColor: Colors.transparent,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onPressed: () {
            setState(() => _loadError = false);
          },
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
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
    );
  }

  Widget _topWidget() {
    EdgeInsets safeArea = _safeArea;

    return Positioned(
      top: safeArea.top + 10,
      left: safeArea.left + 15,
      right: safeArea.right + 15,
      child: Text(
        _chapterList[_currentChapter].title,
        style: TextStyle(
          color: _preferences.fontColor.withOpacity(0.6),
          fontSize: 12,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _bottomWidget() {
    var safeArea = _safeArea;

    return Positioned(
      bottom: safeArea.bottom + 10,
      left: safeArea.left + 15,
      right: safeArea.right + 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              RotatedBox(
                quarterTurns: 1,
                child: Stack(
                  children: <Widget>[
                    Icon(Icons.battery_std, size: 22, color: _preferences.fontColor.withOpacity(0.6)),
                    Positioned(
                      top: 5,
                      left: 7.5,
                      child: Container(
                        width: 7,
                        height: 12.5 * (100 - _batteryLevel) / 100,
                        color: _preferences.background,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Text(
                '${Time.twoDigits(_now.hour)}:${Time.twoDigits(_now.minute)}',
                style: TextStyle(
                  color: _preferences.fontColor.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          Text(
            '第${_currentPage > 0 ? _currentPage + 1 : 1}/${_chapterPages[_currentChapter]?.length ?? 1}页',
            style: TextStyle(
              color: _preferences.fontColor.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Size size = MediaQuery.of(context).size;
    PageTurningPainter painter;

    if (size != Size.zero && size != _size) {
      _size = size;
      _reCalcPages();
    } else {
      _size = size;
    }

    if (size == Size.zero
        || _preferences == null
        || (painter = _getPageTurningPainter()) == null) {
      children.add(Container(
        color: _preferences?.background,
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

      if (_chapterList != null && _chapterList[_currentChapter] != null) {
        children.add(_topWidget());
      }

      children.add(_bottomWidget());
    }

    if (_loadError && !_inDrag) {
      children.add(_reloadWidget());
    }

    if (_inLoading) {
      children.add(_loadingWidget());
    }

    return Stack(
      children: children,
    );
  }
}