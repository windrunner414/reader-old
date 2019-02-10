import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'package:reader/page/reader/turning/simulation.dart';
import 'package:reader/page/reader/turning/coverage.dart';
import 'package:reader/page/reader/calc_pages.dart';
import 'package:reader/page/reader/reader_icon.dart';
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
  String id;

  Chapter({
    @required this.title,
    @required this.id,
  }) : assert(title != null),
       assert(id != null);
}

enum _pageTurningType {
  COVERAGE,
  SIMULATION,
}

class ReaderPreferences {
  _pageTurningType pageTurning;
  Color background;
  Color fontColor;
  double fontSize;
  FontWeight fontWeight;
  double height;
  bool fullScreen;
  bool nightMode;

  Color get realBackground => nightMode ? Colors.black : background;
  Color get realFontColor => nightMode ? Colors.white70 : fontColor;

  static final ReaderPreferences defaultPref = ReaderPreferences(
    pageTurning: _pageTurningType.COVERAGE,
    background: Color.fromRGBO(213, 239, 210, 1),
    fontColor: Colors.black87,
    fontSize: 17,
    fontWeight: FontWeight.normal,
    height: 1.15,
    fullScreen: true,
    nightMode: false,
  );

  ReaderPreferences({
    this.pageTurning,
    this.background,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.fullScreen,
    this.nightMode,
  });

  Map<String, dynamic> toJson() => {
    'pageTurning': pageTurning,
    'background': background?.value,
    'fontColor': fontColor?.value,
    'fontSize': fontSize,
    'fontWeight': fontWeight?.index,
    'height': height,
    'fullScreen': fullScreen,
    'nightMode': nightMode,
  };

  ReaderPreferences.fromJson(Map<String, dynamic> json) :
    pageTurning = json['pageTurning'],
    background = json['background'] != null ? Color(json['background']) : null,
    fontColor = json['fontColor'] != null ? Color(json['fontColor']) : null,
    fontSize = json['fontSize'],
    fontWeight = json['fontWeight'] != null ? FontWeight.values[json['fontWeight']] : null,
    height = json['height'],
    fullScreen = json['fullScreen'],
    nightMode = json['nightMode'];
}

typedef getChapterContentCallback = Future<String> Function(String chapterId);
typedef getChapterListCallback = Future<List<Chapter>> Function();
typedef downloadCallback = Future<void> Function(List<Chapter> downloadChapterList);
typedef isCachedCallback = bool Function(String chapterId);

class Reader extends StatefulWidget {
  final int bookId;
  final String bookName;
  final getChapterContentCallback getChapterContent;
  final getChapterListCallback getChapterList;
  final downloadCallback onDownload;
  final isCachedCallback isCached;
  final WillPopCallback onWillPop;
  final int preloadNum;

  Reader({
    Key key,
    @required this.bookId,
    @required this.bookName,
    @required this.getChapterContent,
    @required this.getChapterList,
    @required this.onDownload,
    @required this.isCached,
    @required this.onWillPop,
    this.preloadNum = 1,
  }) : assert(bookId != null),
       assert(bookName != null),
       assert(getChapterContent != null),
       assert(getChapterList != null),
       assert(onDownload != null),
       assert(isCached != null),
       assert(preloadNum != null && preloadNum >= 0),
       assert(onWillPop != null),
       super(key: key);

  @override
  _ReaderState createState() => _ReaderState();
}

typedef _layerBuilder = Widget Function();

class _ReaderState extends State<Reader> with TickerProviderStateMixin<Reader> {
  ReaderPreferences _preferences;
  ReaderPreferences get preferences => _preferences;

  bool _inDrag = false, _toPrev = false;
  Offset _beginPoint, _currentPoint, _touchStartPoint;

  Ticker _ticker; // ticker for page turning animation.
  double _animDistance;
  double _animDistance2;

  Size _size;
  bool _inLoading = false;
  bool _loadError = false;

  List<Chapter> _chapterList;
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

  EdgeInsets get _safeArea => EdgeInsets.fromWindowPadding(window.padding, window.devicePixelRatio);
  int _batteryLevel = 100;

  List<_layerBuilder> _layer = [];

  ScrollController _chapterListScrollController = ScrollController();

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

    if (_layer.isEmpty) {
      if (_preferences.fullScreen) {
        SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
      } else {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      }
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
      if (k == _currentChapter) {
        int totalPage = _chapterPages[k].length;
        _chapterPages[k] = _calcPages(v);
        _currentPage = (_currentPage / totalPage * _chapterPages[k].length).round();
        return;
      }

      _chapterPages[k] = _calcPages(v);
    });
  }

  List<Picture> _calcPages(String content) {
    return calcPages(
      content: content,
      fontSize: _preferences.fontSize,
      fontWeight: _preferences.fontWeight,
      color: _preferences.realFontColor,
      height: _preferences.height,
      size: _size,
      padding: (const EdgeInsets.fromLTRB(15, 30, 15, 30)).add(_safeArea),
    );
  }

  Future<void> _getChapterList() async {
    List<Chapter> chapterList = await widget.getChapterList();
    if (chapterList != null && chapterList.length > 0) {
      setState(() => _chapterList = chapterList);
    }
  }

  Future<void> _getChapterPages() async {
    if (_inLoading) return;

    _showLoading();
    if (_chapterList == null) {
      await _getChapterList();
      if (_chapterList == null) {
        _hideLoading(false);
        return;
      }
    }

    if (_currentChapter < 0 || _currentChapter >= _chapterList.length) {
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
    if (_cacheId == _currentChapter || _chapterList == null) {
      return;
    }

    int id = _cacheId = _currentChapter;

    int cacheStart = _currentChapter - widget.preloadNum;
    if (cacheStart < 0) cacheStart = 0;
    int cacheEnd = _currentChapter + widget.preloadNum;
    if (cacheEnd >= _chapterList.length) cacheEnd = _chapterList.length - 1;

    List<int> toRemove = [];
    _chapterPages.forEach((int k, List<Picture> v) {
      if (k < cacheStart || k > cacheEnd) {
        toRemove.add(k);
      }
    });
    for (int k in toRemove) {
      _chapterContents.remove(k);
      _chapterPages.remove(k);
    }

    for (int i = cacheStart; i <= cacheEnd; ++i) {
      if (i >= _chapterList.length || _chapterPages[i] != null) continue;
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
      } else {
        _cacheChapters();
      }
    }

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

    PageTurningPainter pageTurningPainter;
    switch (_preferences.pageTurning) {
      case _pageTurningType.COVERAGE:
        pageTurningPainter = CoveragePageTurning(
          touchPoint: _currentPoint,
          prevPage: pages[0],
          currentPage: pages[1],
          nextPage: pages[2],
          background: _preferences.realBackground,
          toPrev: _toPrev,
        );
        break;
      case _pageTurningType.SIMULATION:
        pageTurningPainter = SimulationPageTurningPainter(
          beginTouchPoint: _beginPoint,
          touchPoint: _currentPoint,
          prevPage: pages[0],
          currentPage: pages[1],
          nextPage: pages[2],
          background: _preferences.realBackground,
          toPrev: _toPrev,
        );
        break;
    }

    return pageTurningPainter;
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
    _animDistance = -_currentPoint.dx - 0.01;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _cancelToNextPage() {
    _toPrev = false;
    _animDistance = _size.width - _currentPoint.dx + 0.01; // don't be zero
    _animDistance2 = 0;
    if (_currentPoint.dy < _size.height / 3) {
      _animDistance2 = -_currentPoint.dy;
    } else if (_currentPoint.dy >= _size.height * 2 / 3) {
      _animDistance2 = _size.height - _currentPoint.dy;
    }
    _ticker.start();
  }

  void _toChapter(int chapter) {
    _currentChapter = chapter;
    _currentPage = 0;
    _loadError = false;
  }

  void _onTick(Duration duration) {
    int animDurationMs = 300;
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
    _animDistance -= _animDistance * p;
    _animDistance2 -= _animDistance2 * p;
  }

  bool _canTurningPage() {
    if (_currentChapter < 0 || _currentChapter >= _chapterList.length) return true;
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
        _showLayer(Duration(milliseconds: 100), _toolBarWidget);
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
      _onTick(Duration(milliseconds: 3000)); // stop
    }

    _touchStartPoint = details.globalPosition;
  }

  Future<void> _timer() async {
    int times = 0;
    while (true) {
      _batteryLevel = await Battery().batteryLevel;
      setState(() {});
      await Future.delayed(Duration(seconds: 10));
      if (!mounted) return; // stop timer after dispose
      if (++times % 30 == 0) _getChapterList();
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _ticker = createTicker(_onTick);
    _restoreState();
    _timer();
    super.initState();
  }

  @override
  void dispose() {
    if (_preferences.fullScreen) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    super.dispose();
  }

  Widget _reloadWidget() {
    return Center(
      child: SizedBox(
        width: 240,
        height: 40,
        child: RawMaterialButton(
          child: Text('重新加载'),
          elevation: 0,
          highlightElevation: 0,
          fillColor: Color.fromRGBO(30, 140, 255, 1),
          highlightColor: Color.fromRGBO(20, 120, 255, 1),
          splashColor: Colors.transparent,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          onPressed: () {
            setState(() => _loadError = false);
          },
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
      decoration: BoxDecoration(),
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
          color: _preferences.realFontColor.withOpacity(0.6),
          fontSize: 12,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
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
                    Icon(
                      Icons.battery_std,
                      size: 22,
                      color: _preferences.realFontColor.withOpacity(0.6),
                    ),
                    Positioned(
                      top: 5,
                      left: 7.5,
                      child: Container(
                        width: 7,
                        height: 12.5 * (100 - _batteryLevel) / 100,
                        color: _preferences.realBackground,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 5),
              Text(
                Time.hourMinute,
                style: TextStyle(
                  color: _preferences.realFontColor.withOpacity(0.6),
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
              color: _preferences.realFontColor.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  Widget _iconButton({
    @required IconData icon,
    double size = 24,
    Color color = const Color.fromRGBO(51, 153, 255, 1),
    String text,
    double fontSize = 12,
    @required VoidCallback onPressed,
  }) {
    return text == null ? GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    ) : GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              icon,
              size: size,
              color: color,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolBarWidget() {
    return Positioned(
      top: (45 + _safeArea.top) * (_animDistance - 1),
      bottom: (58 + _safeArea.bottom) * (_animDistance - 1),
      left: 0,
      right: 0,
      child: Stack(
        children: <Widget>[
          _toolBarTopWidget(),
          _toolBarBottomWidget(),
        ],
      ),
    );
  }

  Widget _toolBarTopWidget() {
    EdgeInsets safeArea = _safeArea;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        8 + safeArea.left, safeArea.top,
        15 + safeArea.right, 0,
      ),
      height: 45 + safeArea.top,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                _iconButton(
                  icon: ReaderIcon.back,
                  size: 26,
                  onPressed: () async {
                    if (await widget.onWillPop()) Navigator.pop(context);
                  },
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.bookName,
                    style: TextStyle(
                      color: const Color.fromRGBO(51, 153, 255, 1),
                      decoration: TextDecoration.none,
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              _iconButton(
                icon: ReaderIcon.download,
                onPressed: () {

                },
              ),
              SizedBox(width: 15),
              _iconButton(
                icon: ReaderIcon.info,
                onPressed: () {

                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolBarBottomWidget() {
    EdgeInsets safeArea = _safeArea;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          safeArea.left,
          8,
          safeArea.right,
          8 + safeArea.bottom,
        ),
        height: 58 + safeArea.bottom,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _iconButton(
              icon: ReaderIcon.catalogue,
              text: '目录',
              onPressed: () {
                _showLayer(Duration(milliseconds: 250), _catalogueWidget);
              },
            ),
            _preferences.nightMode
            ? _iconButton(
              icon: ReaderIcon.sun,
              text: '日间模式',
              onPressed: () {
                setPreferences(ReaderPreferences(nightMode: false));
              },
            )
            : _iconButton(
              icon: ReaderIcon.moon,
              size: 21,
              text: '夜间模式',
              onPressed: () {
                setPreferences(ReaderPreferences(nightMode: true));
              },
            ),
            _iconButton(
              icon: ReaderIcon.setting,
              text: '设置',
              onPressed: () {

              },
            ),
            _iconButton(
              icon: ReaderIcon.progress,
              text: '进度',
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _maskWidget(Duration duration) {
    return WillPopScope(
      child: GestureDetector(
        onPanStart: (DragStartDetails details) {
          _closeLayer(duration);
        },
        child: Container(
          width: _size.width,
          height: _size.height,
          decoration: BoxDecoration(),
        ),
      ),
      onWillPop: () {
        _closeLayer(duration);
        return Future.value(false);
      },
    );
  }

  TickerFuture _showLayer(Duration duration, _layerBuilder builder) {
    if (_ticker.isActive) _onTick(Duration(milliseconds: 3000));
    if (_preferences.fullScreen) SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _animDistance = 0;

    _layer = [
      () => _maskWidget(duration),
      builder,
      () => Container(
        width: _size.width,
        height: _size.height,
        decoration: BoxDecoration(),
      ),
    ];

    Ticker ticker;
    ticker = createTicker((Duration d) {
      setState(() {
        if (d.inMilliseconds >= duration.inMilliseconds) {
          _animDistance = 1;
          _layer.removeLast();
          ticker.stop();
        } else {
          _animDistance = d.inMilliseconds / duration.inMilliseconds;
        }
      });
    });

    return ticker.start();
  }

  TickerFuture _closeLayer(Duration duration) {
    setState(() {
      _layer.add(() => Container(
        width: _size.width,
        height: _size.height,
        decoration: BoxDecoration(),
      ));
    });
    Ticker ticker;
    ticker = createTicker((Duration d) {
      setState(() {
        if (d.inMilliseconds >= duration.inMilliseconds) {
          _animDistance = 0;
          _layer.clear();
          if (_preferences.fullScreen) SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
          ticker.stop();
        } else {
          _animDistance = 1 - d.inMilliseconds / duration.inMilliseconds;
        }
      });
    });

    return ticker.start();
  }

  Widget _catalogueWidget() {
    double width = _size.width * 0.9;
    double listViewHeight = (_size.height - _safeArea.top - _safeArea.bottom - 85.0);
    double maxScrollOffset = 50.0 * _chapterList.length - listViewHeight;
    if (maxScrollOffset < 0.0) maxScrollOffset = 0.0;
    if (!_chapterListScrollController.hasClients) {
      _chapterListScrollController = ScrollController(
        initialScrollOffset: (50.0 * _currentChapter).clamp(0.0, maxScrollOffset),
        keepScrollOffset: false,
      );
    }
    double scrollOffset = _chapterListScrollController.hasClients
                          ? _chapterListScrollController.offset
                          : _chapterListScrollController.initialScrollOffset;
    double scrollProgress = maxScrollOffset == 0.0 ? 0.0 : scrollOffset / maxScrollOffset;
    _chapterListScrollController.addListener(() => setState(() {}));

    return Positioned(
      left: width * (_animDistance - 1),
      child: Container(
        width: width,
        height: _size.height,
        padding: EdgeInsets.only(right: -_safeArea.right).add(_safeArea),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: 85,
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.bookName,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                      color: Colors.black87,
                      height: 0.8,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '目录',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          color: Colors.black87,
                        ),
                      ),
                      _iconButton(
                        icon: Icons.refresh,
                        size: 23,
                        color: Colors.black54,
                        onPressed: () async {
                          _showLoading();
                          await _getChapterList();
                          _hideLoading();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: ListView.builder(
                      controller: _chapterListScrollController,
                      padding: EdgeInsets.zero,
                      itemExtent: 50,
                      itemCount: _chapterList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FlatButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          highlightColor: const Color.fromRGBO(0, 0, 0, 0.1),
                          splashColor: const Color.fromRGBO(0, 0, 0, 0.03),
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _chapterList[index].title,
                              style: TextStyle(
                                color: _currentChapter == index
                                    ? const Color.fromRGBO(51, 153, 255, 1)
                                    : (widget.isCached(_chapterList[index].id)
                                      ? const Color.fromRGBO(98, 106, 115, 1)
                                      : const Color.fromRGBO(162, 171, 179, 1)),
                                fontSize: 14,
                                height: 0.8,
                              ),
                              softWrap: true,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onPressed: () {
                            _toChapter(index);
                            _closeLayer(Duration(milliseconds: 250));
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: scrollProgress * (listViewHeight - 27),
                    right: 1,
                    child: GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        double p = details.primaryDelta / (listViewHeight - 27) * maxScrollOffset;
                        double value = (_chapterListScrollController.offset + p).clamp(0.0, maxScrollOffset);
                        _chapterListScrollController.jumpTo(value);
                      },
                      child: Container(
                        width: 15,
                        height: 27,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 1)],
                          color: const Color.fromRGBO(245, 245, 245, 1),
                        ),
                        child: Icon(Icons.menu, size: 14, color: Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Size size = MediaQuery.of(context).size;

    if (size != Size.zero && size != _size) {
      _size = size;
      _reCalcPages();
    } else {
      _size = size;
    }

    if (size == Size.zero || _preferences == null) {
      children.add(Container(
        color: _preferences?.realBackground,
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
            painter: _getPageTurningPainter(),
          ),
        ),
      ));
    }

    if (_chapterList != null && _currentChapter >= 0 && _currentChapter < _chapterList.length) {
      children.add(_topWidget());
    }

    if (_preferences != null) {
      children.add(_bottomWidget());
    }

    if (_loadError && !_inDrag) {
      children.add(_reloadWidget());
    }

    _layer.forEach((_layerBuilder builder) => children.add(builder()));

    if (_inLoading) {
      children.add(_loadingWidget());
    }

    return WillPopScope(
      onWillPop: widget.onWillPop,
      child: Stack(
        children: children,
      ),
    );
  }
}