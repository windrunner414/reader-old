import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'package:reader/page/reader/calc_pages.dart';
import 'package:reader/page/reader/reader_icon.dart';
import 'package:reader/utils/local_storage.dart';
import 'package:reader/utils/time.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:battery/battery.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';

class Chapter {
  String title;
  String id;

  Chapter({
    @required this.title,
    @required this.id,
  }) : assert(title != null),
       assert(id != null);
}

enum _PageTurningType {
  COVERAGE,
  TRANSLATION,
  SIMULATION,
  ROLL,
  NONE,
}

class ReaderPreferences {
  final _PageTurningType pageTurning;
  final Color background;
  final Color fontColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final double paragraphHeight;
  final bool fullScreen;
  final bool nightMode;

  Color get realBackground => nightMode ? Color.fromRGBO(34, 34, 34, 1) : background;
  Color get realFontColor => nightMode ? Color.fromRGBO(124, 124, 124, 1) : fontColor;

  Color get menuFontColor => Color.fromRGBO(51, 153, 255, 1);
  Color get menuBackground => nightMode ? Color.fromRGBO(22, 22, 22, 1) : Colors.white;

  static const ReaderPreferences defaultPref = ReaderPreferences(
    pageTurning: _PageTurningType.COVERAGE,
    background: Color.fromRGBO(213, 239, 210, 1),
    fontColor: Colors.black87,
    fontSize: 18,
    fontWeight: FontWeight.normal,
    height: 1.3,
    paragraphHeight: 2,
    fullScreen: true,
    nightMode: false,
  );

  const ReaderPreferences({
    this.pageTurning,
    this.background,
    this.fontColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.paragraphHeight,
    this.fullScreen,
    this.nightMode,
  });

  Map<String, dynamic> toJson() => {
    'pageTurning': pageTurning?.index,
    'background': background?.value,
    'fontColor': fontColor?.value,
    'fontSize': fontSize,
    'fontWeight': fontWeight?.index,
    'height': height,
    'paragraphHeight': paragraphHeight,
    'fullScreen': fullScreen,
    'nightMode': nightMode,
  };

  ReaderPreferences.fromJson(Map<String, dynamic> json) :
    pageTurning = json['pageTurning'] != null ? _PageTurningType.values[json['pageTurning']] : null,
    background = json['background'] != null ? Color(json['background']) : null,
    fontColor = json['fontColor'] != null ? Color(json['fontColor']) : null,
    fontSize = json['fontSize'],
    fontWeight = json['fontWeight'] != null ? FontWeight.values[json['fontWeight']] : null,
    height = json['height'],
    paragraphHeight = json['paragraphHeight'],
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
       assert(preloadNum != null && preloadNum >= 1),
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
  int _touchStartMilliseconds;

  Ticker _ticker; // ticker for page turning animation.
  double _animDistance;
  double _animDistance2;

  Size _size;
  Size _pageSize;
  bool _inLoading = false;
  bool _loadError = false;

  List<Chapter> _chapterList = [];
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

  Map<int, List> _chapterPages = {};
  Map<int, String> _chapterContents = {};
  Map<int, int> _cachingChapters = {};

  EdgeInsets _safeArea = EdgeInsets.zero;
  EdgeInsets _pageSafeArea = EdgeInsets.zero;
  int _batteryLevel = 100;

  List<_layerBuilder> _layer = [];
  bool _preventPageSafeAreaChange = false;

  ScrollController _chapterListScrollController = ScrollController();
  Timer _progressTimer;
  Timer _refreshChapterListTimer;
  Timer _updateSystemStatusTimer;
  int _progressTempChapter;

  RollPageTurningController _rollPageTurningController;
  double get _rollPageTurningScrollHeight =>
    _pageSize.height - _pageSafeArea.top - _pageSafeArea.bottom - _pagePadding.top - _pagePadding.bottom;
  EdgeInsets _pagePadding = const EdgeInsets.fromLTRB(20, 30, 20, 30);

  PageTurningPainter _painter;
  bool get isRollPageTurning => _preferences.pageTurning == _PageTurningType.ROLL;

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

  void _setFullScreen(bool fullScreen) {
    SystemChrome.setEnabledSystemUIOverlays(fullScreen ? [] : SystemUiOverlay.values);
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
      _setFullScreen(_preferences.fullScreen);
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

  int _getTotalPage(int chapter) {
    if (_chapterPages[chapter] == null) return 1;
    return (_chapterPages[chapter].length == 3 && _chapterPages[chapter][2].runtimeType == int)
        ? _chapterPages[chapter][2] : _chapterPages[chapter].length;
  }

  void _reCalcPages() {
    _chapterContents.forEach((int k, String v) {
      if (k == _currentChapter) {
        int totalPage = _getTotalPage(k);
        _chapterPages[k] = _calcPages(v);
        int newTotalPage = _getTotalPage(k);
        _currentPage = (_currentPage / totalPage * newTotalPage).round();
        _rollPageTurningController = null;
        return;
      }

      _chapterPages[k] = _calcPages(v);
    });
  }

  List _calcPages(String content) =>
    calcPages(
      content: content,
      fontSize: _preferences.fontSize,
      fontWeight: _preferences.fontWeight,
      color: _preferences.realFontColor,
      height: _preferences.height,
      paragraphHeight: _preferences.paragraphHeight,
      size: isRollPageTurning ? Size(_pageSize.width, _rollPageTurningScrollHeight) : _pageSize,
      padding: isRollPageTurning
        ? EdgeInsets.fromLTRB(_pagePadding.left + _pageSafeArea.left, 0, _pagePadding.right + _pageSafeArea.right, 0)
        : _pagePadding.add(_pageSafeArea),
      isRoll: isRollPageTurning,
    );

  Future<void> _getChapterList([bool showLoading = false]) async {
    if (_inLoading && _chapterList.isNotEmpty) return;
    if (showLoading) _showLoading();
    List<Chapter> chapterList = await widget.getChapterList();
    if (chapterList != null && chapterList.isNotEmpty) {
      if (_refreshChapterListTimer == null) {
        _refreshChapterListTimer = Timer.periodic(Duration(minutes: 5), (Timer timer) => _getChapterList());
      }
      _chapterList = chapterList;
      if (_currentChapter != _currentChapter.clamp(0, _chapterList.length - 1)) {
        _toChapter(_currentChapter);
      }
      setState(() {});
    }
    if (showLoading) _hideLoading();
  }

  Future<void> _getChapterPages() async {
    if (_inLoading) return;

    _showLoading();
    if (_chapterList.isEmpty) {
      await _getChapterList();
      if (_chapterList.isEmpty) {
        _hideLoading(false);
        return;
      }
    }

    _currentChapter = _currentChapter.clamp(0, _chapterList.length - 1);

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
    if (_chapterList.isEmpty) return;

    var getCacheRange = () {
      int cacheStart = _currentChapter - widget.preloadNum;
      if (cacheStart < 0) cacheStart = 0;
      int cacheEnd = _currentChapter + widget.preloadNum;
      if (cacheEnd >= _chapterList.length) cacheEnd = _chapterList.length - 1;
      return [cacheStart, cacheEnd];
    };

    var inCacheRange = (int i, [List<int> cacheRange]) {
      cacheRange ??= getCacheRange();
      return i >= cacheRange[0] && i <= cacheRange[1];
    };

    List<int> cacheRange = getCacheRange();
    List<int> toRemove = [];
    _chapterPages.forEach((int k, List v) {
      if (!inCacheRange(k, cacheRange)) {
        toRemove.add(k);
      }
    });
    for (int k in toRemove) {
      _chapterContents.remove(k);
      _chapterPages.remove(k);
    }

    for (int i = cacheRange[0]; i <= cacheRange[1]; ++i) {
      if (!inCacheRange(i)
          || _chapterPages[i] != null
          || _cachingChapters[i] != null) continue;

      _cachingChapters[i] = 1;
      String content = await widget.getChapterContent(_chapterList[i].id);

      if (content == null || content.isEmpty
          || _chapterPages[i] != null
          || !inCacheRange(i)) continue;

      _chapterContents[i] = content;
      _chapterPages[i] = _calcPages(content);
      _cachingChapters.remove(i);
    }
  }

  List _getPages() {
    if (!_loadError) {
      if (_chapterPages[_currentChapter] == null) {
        _getChapterPages();
        if (!isRollPageTurning) return null;
      } else {
        _cacheChapters();
      }
    }

    if (isRollPageTurning) {
      List emptyPage = [null, _rollPageTurningScrollHeight];
      return _chapterList.isEmpty ? [[null, 0.0], emptyPage, [null, 0.0]] : [
        _chapterPages[_currentChapter - 1] ?? (_currentChapter > 0 ? emptyPage : [null, 0.0]),
        _chapterPages[_currentChapter] ?? emptyPage,
        _chapterPages[_currentChapter + 1] ?? (_currentChapter < _chapterList.length - 1 ? emptyPage : [null, 0.0]),
      ];
    }

    List<Picture> currentChapterPages = _chapterPages[_currentChapter] ?? [null];
    List<Picture> returnPages = [];

    if (_currentPage == -1) {
      _currentPage += currentChapterPages.length;
    }

    _currentPage = _currentPage.clamp(0, currentChapterPages.length - 1);

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
    List pages = _getPages();
    if (pages == null) return null;

    PageTurningPainter pageTurningPainter;
    switch (_preferences.pageTurning) {
      case _PageTurningType.COVERAGE:
        pageTurningPainter = CoveragePageTurningPainter(
          beginTouchPoint: _beginPoint,
          touchPoint: _currentPoint,
          prevPage: pages[0],
          currentPage: pages[1],
          nextPage: pages[2],
          background: _preferences.realBackground,
          toPrev: _toPrev,
        );
        break;
      case _PageTurningType.TRANSLATION:
        pageTurningPainter = TranslationPageTurningPainter(
          beginTouchPoint: _beginPoint,
          touchPoint: _currentPoint,
          prevPage: pages[0],
          currentPage: pages[1],
          nextPage: pages[2],
          background: _preferences.realBackground,
          toPrev: _toPrev,
        );
        break;
      case _PageTurningType.SIMULATION:
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
      case _PageTurningType.NONE:
        pageTurningPainter = NonePageTurningPainter(
          background: _preferences.realBackground,
          currentPage: pages[1],
        );
        break;
      case _PageTurningType.ROLL:
        if (_rollPageTurningController == null) {
          _rollPageTurningController = RollPageTurningController(
            vsync: this,
            onMotion: () => setState(() {}),
            initialPage: _currentPage,
          );
        }
        pageTurningPainter = RollPageTurningPainter(
          controller: _rollPageTurningController,
          inLoading: _inLoading,
          beginTouchPoint: _beginPoint,
          touchPoint: _currentPoint,
          prevChapter: pages[0],
          currentChapter: pages[1],
          nextChapter: pages[2],
          background: _preferences.realBackground,
          padding: EdgeInsets.fromLTRB(0, _pagePadding.top + _pageSafeArea.top, 0, _pagePadding.bottom + _pageSafeArea.bottom),
          onPageChange: (int page) {
            Future.delayed(Duration.zero).then((_) => setState(() => _currentPage = page));
          },
          toNextChapter: () {
            ++_currentChapter;
            _currentPage = 0;
            _loadError = false;
            Future.delayed(Duration.zero).then((_) => setState(() {}));
          },
          toPrevChapter: () {
            --_currentChapter;
            _currentPage = 0;
            _loadError = false;
            Future.delayed(Duration.zero).then((_) => setState(() {}));
          },
          loadPrevChapter: () async {
            if (_currentChapter - 1 < 0) return;
            _rollLoadChapter(_currentChapter - 1);
          },
          loadNextChapter: () async {
            if (_currentChapter + 1 > _chapterList.length - 1) return;
            _rollLoadChapter(_currentChapter + 1);
          },
        );
        break;
    }

    return pageTurningPainter;
  }

  void _rollLoadChapter(int chapter) async {
    if (_inLoading) return;
    if (_chapterPages[chapter] != null) return;
    _inLoading = true;
    await Future.delayed(Duration.zero);
    _showLoading();
    String content = await widget.getChapterContent(_chapterList[chapter].id);
    if (content == null || content.isEmpty) {
      _hideLoading(false);
      _currentChapter = chapter;
      return;
    }

    _chapterContents[chapter] = content;
    _chapterPages[chapter] = _calcPages(content);
    _hideLoading();
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
    _animDistance = 2 * _size.width - _currentPoint.dx;
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
    _animDistance = -_currentPoint.dx - _size.width;
    if (_currentPoint.dy < _size.height / 3) {
      _animDistance2 = -_currentPoint.dy;
    } else if (_currentPoint.dy >= _size.height * 2 / 3) {
      _animDistance2 = _size.height - _currentPoint.dy;
    } else {
      _animDistance2 = 0;
    }
    _ticker.start();
  }

  void _cancelToPrevPage() {
    _toPrev = true;
    _animDistance = -_currentPoint.dx - _size.width;
    _animDistance2 = 0;
    _ticker.start();
  }

  void _cancelToNextPage() {
    _toPrev = false;
    _animDistance = 2 * _size.width - _currentPoint.dx;
    if (_currentPoint.dy < _size.height / 3) {
      _animDistance2 = -_currentPoint.dy;
    } else if (_currentPoint.dy >= _size.height * 2 / 3) {
      _animDistance2 = _size.height - _currentPoint.dy;
    } else {
      _animDistance2 = 0;
    }
    _animDistance2 *= _animDistance / (_size.width - _currentPoint.dx);
    _ticker.start();
  }

  void _toChapter(int chapter) {
    if (_ticker.isActive) {
      _toPrev = true;
      _animDistance = -1; // cancel
      _onTick(Duration(milliseconds: -1));
    }
    _rollPageTurningController?.stopMotion();
    _currentChapter = chapter.clamp(0, _chapterList.length - 1);
    _currentPage = 0;
    _loadError = false;
    _rollPageTurningController = null;
  }

  void _onTick(Duration duration) {
    int animDurationMs;
    switch (_preferences.pageTurning) {
      case _PageTurningType.ROLL:
        return;
      case _PageTurningType.SIMULATION:
        animDurationMs = 1800;
        break;
      case _PageTurningType.COVERAGE:
        animDurationMs = 2600;
        break;
      case _PageTurningType.TRANSLATION:
        animDurationMs = 2600;
        break;
      case _PageTurningType.NONE:
        animDurationMs = 0;
        break;
    }

    if (duration.inMicroseconds < 0 || duration.inMilliseconds >= animDurationMs || _animDistance == 0) {
      _ticker.stop();
      setState(() {
        _resetTouch();
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
    if (_chapterList.isEmpty) return false;
    if (_toPrev) {
      return _currentChapter > 0 || _currentPage > 0;
    } else {
      return _currentChapter < _chapterList.length - 1
          || _currentPage < (_chapterPages[_currentChapter]?.length ?? 1) - 1;
    }
  }

  void _resetTouch() {
    _inDrag = false;
    _beginPoint = _currentPoint = _touchStartPoint = null;
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

        if (!isRollPageTurning && !_canTurningPage()) {
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
      _resetTouch();
      return;
    }

    if (_currentPoint == null) {
      // on click
      if (DateTime.now().millisecondsSinceEpoch - _touchStartMilliseconds > 500) {
        _resetTouch();
        return;
      }

      if (isRollPageTurning) {
        _showLayer(Duration(milliseconds: 100), _toolBarWidget, true);
        _resetTouch();
        return;
      }

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
        _showLayer(Duration(milliseconds: 100), _toolBarWidget, true);
        _resetTouch();
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

    if (isRollPageTurning) {
      setState(() => _resetTouch());
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

  void _onPanDown(DragDownDetails details) {
    if (_ticker.isActive) {
      _onTick(Duration(milliseconds: -1)); // stop
    }
    _rollPageTurningController?.stopMotion();
    _touchStartPoint = details.globalPosition;
    _touchStartMilliseconds = DateTime.now().millisecondsSinceEpoch;
  }

  void _updateSystemStatus(Timer timer) async {
    try {
      _batteryLevel = await Battery().batteryLevel;
    } catch (_) {
      _batteryLevel = -1;
    }
    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
    else fn();
  }

  @override
  void initState() {
    _ticker = createTicker(_onTick);
    _restoreState();
    _updateSystemStatus(null);
    _updateSystemStatusTimer = Timer.periodic(Duration(seconds: 5), _updateSystemStatus);
    super.initState();
  }

  @override
  void dispose() {
    if (_preferences.fullScreen) {
      _setFullScreen(false);
    }
    _progressTimer?.cancel();
    _updateSystemStatusTimer?.cancel();
    _refreshChapterListTimer?.cancel();
    _rollPageTurningController?.stopMotion();
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
    return Positioned(
      top: _pageSafeArea.top + 8,
      left: _pageSafeArea.left + _pagePadding.left,
      right: _pageSafeArea.right + _pagePadding.right,
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
    int cpage = _currentPage > 0 ? _currentPage + 1 : 1;
    int tpage = _getTotalPage(_currentChapter);

    return Positioned(
      bottom: _pageSafeArea.bottom + 8,
      left: _pageSafeArea.left + _pagePadding.left,
      right: _pageSafeArea.right + _pagePadding.right,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              _batteryLevel >= 0 ? RotatedBox(
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
              ) : Container(),
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
            '第${cpage.clamp(1, tpage)}/$tpage页',
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
    Color color,
    String text,
    double fontSize = 12,
    @required VoidCallback onPressed,
  }) {
    if (color == null) {
      color = preferences.menuFontColor;
    }
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
    return Container(
      color: preferences.menuBackground,
      padding: EdgeInsets.fromLTRB(
        8 + _safeArea.left, _safeArea.top,
        15 + _safeArea.right, 0,
      ),
      height: 45 + _safeArea.top,
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
                      color: preferences.menuFontColor,
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
                  _showLayer(Duration(milliseconds: 100), _downloadWidget);
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: preferences.menuBackground,
        padding: EdgeInsets.fromLTRB(
          _safeArea.left,
          8,
          _safeArea.right,
          8 + _safeArea.bottom,
        ),
        height: 58 + _safeArea.bottom,
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
                _showLayer(Duration(milliseconds: 100), _settingWidget);
              },
            ),
            _iconButton(
              icon: ReaderIcon.progress,
              text: '进度',
              onPressed: () {
                _showLayer(Duration(milliseconds: 100), _progressWidget);
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
        onPanDown: (DragDownDetails details) {
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

  TickerFuture _showLayer(Duration duration, _layerBuilder builder, [bool exitFullScreen = false]) {
    if (_ticker.isActive) _onTick(Duration(milliseconds: -1));
    if (_preferences.fullScreen && exitFullScreen) {
      _preventPageSafeAreaChange = true;
      _setFullScreen(false);
    } else if (_preventPageSafeAreaChange) {
      if (_preferences.fullScreen) _setFullScreen(true);
      Timer(Duration(milliseconds: 100), () => setState(() => _preventPageSafeAreaChange = false));
    }
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
    if (_preferences.fullScreen) _setFullScreen(true);
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
          _preventPageSafeAreaChange = false;
          ticker.stop();
        } else {
          _animDistance = 1 - d.inMilliseconds / duration.inMilliseconds;
        }
      });
    });

    return ticker.start();
  }

  Widget _downloadButton({String text, VoidCallback onPressed}) {
    return FlatButton(
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: SizedBox(
        height: 40,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: preferences.menuFontColor,
            ),
          ),
        ),
      ),
      onPressed: onPressed,
    );
  }

  Widget _downloadWidget() {
    List<Widget> children = [
      SizedBox(
        height: 50,
        child: Center(
          child: Text(
            '请选择缓存范围',
            style: TextStyle(
              fontSize: 18,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
              color: preferences.menuFontColor,
            ),
          ),
        ),
      ),
      _downloadButton(
        text: '后面50章',
        onPressed: () {},
      ),
      _downloadButton(
        text: '后面100章',
        onPressed: () {},
      ),
      _downloadButton(
        text: '后面全部',
        onPressed: () {},
      ),
      _downloadButton(
        text: '全部章节',
        onPressed: () {},
      ),
      SizedBox(height: 8),
    ];
    return Center(
      child: Opacity(
        opacity: _animDistance,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: preferences.menuBackground,
          ),
          width: 200,
          height: 40.0 * 4 + 50.0 + 8.0,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
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
        color: preferences.menuBackground,
        child: Column(
          children: <Widget>[
            Container(
              height: 85,
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
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
                      color: preferences.nightMode ? Colors.white70 : Colors.black87,
                    ),
                    softWrap: true,
                    maxLines: 1,
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
                          color: preferences.nightMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      _iconButton(
                        icon: Icons.refresh,
                        size: 23,
                        color: preferences.nightMode ? Colors.white54 : Colors.black54,
                        onPressed: () async {
                          await _getChapterList(true);
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
                        bool isCached = widget.isCached(_chapterList[index].id);
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
                                    ? preferences.menuFontColor
                                    : (((preferences.nightMode && !isCached) || (!preferences.nightMode && isCached))
                                      ? const Color.fromRGBO(98, 106, 115, 1)
                                      : const Color.fromRGBO(162, 171, 179, 1)),
                                fontSize: 14,
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
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details) {
                        double p = details.primaryDelta / (listViewHeight - 27) * maxScrollOffset;
                        double value = (_chapterListScrollController.offset + p).clamp(0.0, maxScrollOffset);
                        _chapterListScrollController.jumpTo(value);
                      },
                      child: Container(
                        width: 20,
                        height: 27,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 1)],
                          color: preferences.nightMode ? Color.fromRGBO(160, 160, 160, 1) : Color.fromRGBO(245, 245, 245, 1),
                        ),
                        child: Icon(Icons.menu, size: 15, color: Colors.black26),
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

  Widget _settingWidget() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: (150 + _safeArea.bottom) * (_animDistance - 1),
      child: Container(
        padding: EdgeInsets.fromLTRB(_safeArea.left, 0, _safeArea.right, _safeArea.bottom),
        height: 150 + _safeArea.bottom,
        color: preferences.menuBackground,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(onPressed: () {setPreferences(ReaderPreferences(pageTurning: _PageTurningType.COVERAGE));}, child: Text('覆盖')),
                FlatButton(onPressed: () {setPreferences(ReaderPreferences(pageTurning: _PageTurningType.TRANSLATION));}, child: Text('平移')),
                FlatButton(onPressed: () {setPreferences(ReaderPreferences(pageTurning: _PageTurningType.SIMULATION));}, child: Text('仿真')),
                FlatButton(onPressed: () {setPreferences(ReaderPreferences(pageTurning: _PageTurningType.ROLL));}, child: Text('上下')),
                FlatButton(onPressed: () {setPreferences(ReaderPreferences(pageTurning: _PageTurningType.NONE));}, child: Text('无')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressWidget() {
    var stopTimer = () {
      _progressTimer?.cancel();
      _progressTimer = null;
      if (_progressTempChapter == _currentChapter) _progressTempChapter = null;
      if (_progressTempChapter == null) return;
      Future.delayed(Duration.zero, () => setState(() {
        _toChapter(_progressTempChapter);
        _progressTempChapter = null;
      }));
    };

    var startTimer = (VoidCallback fn) {
      _progressTimer?.cancel();
      _progressTempChapter ??= _currentChapter;
      _progressTimer = Timer.periodic(Duration(milliseconds: 80), (Timer timer) {
        setState(fn);
      });
    };

    return Positioned(
      left: 0,
      right: 0,
      bottom: (140 + _safeArea.bottom) * (_animDistance - 1),
      height: (140 + _safeArea.bottom),
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Center(
                child: Container(
                  height: 65,
                  padding: EdgeInsets.fromLTRB(15 + _safeArea.left, 4, 15 + _safeArea.right, 4),
                  decoration: BoxDecoration(
                    color: preferences.menuBackground,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        _chapterList[
                        (_progressTempChapter ?? _currentChapter).clamp(0, _chapterList.length - 1)
                        ].title,
                        style: TextStyle(
                          fontSize: 16,
                          color: preferences.menuFontColor,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _chapterList.length == 1 ? '100%' : '${(((_progressTempChapter ?? _currentChapter)
                            .clamp(0, _chapterList.length - 1)) / (_chapterList.length - 1) * 100)
                            .toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          color: preferences.menuFontColor,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60 + _safeArea.bottom,
                padding: EdgeInsets.fromLTRB(_safeArea.left + 15, 0, _safeArea.right + 15, _safeArea.bottom),
                color: preferences.menuBackground,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTapDown: (_) {
                        _progressTimer?.cancel();
                        _progressTimer = Timer(Duration(milliseconds: 500), () {
                          startTimer(() => --_progressTempChapter);
                        });
                      },
                      onTapUp: (_) {
                        if (_progressTimer == null) return;
                        if (_progressTimer.tick == 0) {
                          _progressTempChapter ??= _currentChapter;
                          if (_progressTempChapter <= 0) Fluttertoast.showToast(msg: '没有上一章了');
                          else --_progressTempChapter;
                        }
                        stopTimer();
                      },
                      onTapCancel: stopTimer,
                      child: Text(
                        '上一章',
                        style: TextStyle(
                          fontSize: 14,
                          color: preferences.menuFontColor,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: SeekBar(
                          progresseight: 6,
                          min: 0,
                          max: _chapterList.length.toDouble(),
                          value: _progressTempChapter?.toDouble() ?? _currentChapter.toDouble(),
                          onValueChanged: (ProgressValue value, bool isEnd) {
                            _progressTimer?.cancel();
                            _progressTempChapter = value.value.round();
                            if (isEnd) {
                              stopTimer();
                            } else {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) {
                        _progressTimer?.cancel();
                        _progressTimer = Timer(Duration(milliseconds: 500), () {
                          startTimer(() => ++_progressTempChapter);
                        });
                      },
                      onTapUp: (_) {
                        if (_progressTimer == null) return;
                        if (_progressTimer.tick == 0) {
                          _progressTempChapter ??= _currentChapter;
                          if (_progressTempChapter >= _chapterList.length - 1) Fluttertoast.showToast(msg: '没有下一章了');
                          else ++_progressTempChapter;
                        }
                        stopTimer();
                      },
                      onTapCancel: stopTimer,
                      child: Text(
                        '下一章',
                        style: TextStyle(
                          fontSize: 14,
                          color: preferences.menuFontColor,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.arrow_drop_down,
                size: 46,
                color: preferences.menuBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    Size size = MediaQuery.of(context).size;
    EdgeInsets safeArea = EdgeInsets.fromLTRB(
      0, MediaQuery.of(context).padding.top,
      0, window.padding.bottom > 0 ? 8 : 0,
    );
    EdgeInsets pageSafeArea = safeArea;
    bool needReCalcPages = false;

    if (_painter != null) {
      if (_ticker.isActive && _painter.isAnimEnd) {
        _onTick(Duration(milliseconds: -1));
      }
      _painter = null;
    }

    if (!_preventPageSafeAreaChange && pageSafeArea != _pageSafeArea) {
      needReCalcPages = true;
      _pageSafeArea = pageSafeArea;
    }
    _safeArea = safeArea;

    if (!_preventPageSafeAreaChange && size != Size.zero && size != _pageSize) {
      needReCalcPages = true;
      _pageSize = size;
    }
    _size = size;

    if (needReCalcPages) _reCalcPages();

    if (size == Size.zero || _preferences == null || (_painter = _getPageTurningPainter()) == null) {
      children.add(Container(
        color: _preferences?.realBackground,
      ));
    } else {
      children.add(RepaintBoundary(
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanDown: _onPanDown,
          child: CustomPaint(
            size: size,
            isComplex: true,
            willChange: _inDrag,
            painter: _painter,
          ),
        ),
      ));
    }

    if (_currentChapter != null && _currentChapter >= 0 && _currentChapter < _chapterList.length) {
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

    return _layer.isNotEmpty
      ? Stack(
          children: children,
        )
      : WillPopScope(
          onWillPop: widget.onWillPop,
          child: Stack(
            children: children,
          ),
        );
  }
}