import 'package:flutter/material.dart';
import 'page_turning.dart';

class RollPageTurningController {
  double scrollOffset;
  Offset lastTouchPoint;
  int lastTouchMilliseconds;
  double jumpToEnd = -1;
  final TickerProvider vsync;
  final VoidCallback onMotion;
  int page;
  int initialPage;
  AnimationController _animationController;
  double velocity;
  double _lastMotionValue;

  bool get isAnimEnd => _animationController == null;

  void scroll(double offset) {
    scrollOffset += offset;
    initialPage = null;
  }

  void scrollTo(double offset) {
    scrollOffset = offset;
    initialPage = null;
  }

  void startMotion({
    double lowerBound = double.negativeInfinity,
    double upperBound = double.infinity,
  }) {
    if (_animationController != null) stopMotion();
    if (velocity == null || velocity.abs() < 150) return;
    velocity = velocity.clamp(-10000.0, 10000.0);

    _lastMotionValue = 0;
    Simulation simulation = ClampingScrollSimulation(position: 0, velocity: velocity);
    _animationController = AnimationController(
      vsync: vsync,
      lowerBound: lowerBound,
      upperBound: upperBound,
    )..addListener(_animListener)
      ..addStatusListener(_animStatusListener)
      ..animateWith(simulation);
  }

  void stopMotion() {
    _animationController?.stop();
    _animationController = null;
    _lastMotionValue = null;
  }

  void _animStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed
        || status == AnimationStatus.dismissed) {
      stopMotion();
    }
  }
  
  void _animListener() {
    scroll(_animationController.value - _lastMotionValue);
    _lastMotionValue = _animationController.value;
    if (_animationController.value == _animationController.upperBound
        || _animationController.value == _animationController.lowerBound) {
      stopMotion();
    }
    onMotion();
  }

  RollPageTurningController({
    this.scrollOffset = 0,
    @required this.vsync,
    @required this.onMotion,
    this.initialPage,
  }) : assert(vsync != null),
       assert(onMotion != null);
}

class RollPageTurningPainter extends PageTurningPainter {
  @override
  bool get isAnimEnd => controller.isAnimEnd;

  final RollPageTurningController controller;
  final EdgeInsets padding;
  final VoidCallback toNextChapter, toPrevChapter, loadNextChapter, loadPrevChapter;
  final void Function(int) onPageChange;
  final List prevChapter, currentChapter, nextChapter;
  final Color background;
  final Offset beginTouchPoint, touchPoint;
  final bool inLoading;

  RollPageTurningPainter({
    @required this.controller,
    @required this.padding,
    @required this.toNextChapter,
    @required this.toPrevChapter,
    @required this.loadNextChapter,
    @required this.loadPrevChapter,
    @required this.onPageChange,
    @required this.prevChapter,
    @required this.currentChapter,
    @required this.nextChapter,
    @required this.background,
    @required this.beginTouchPoint,
    @required this.touchPoint,
    @required this.inLoading,
  });

  @override
  void paint(Canvas _canvas, Size _size) {
    canvas = _canvas;
    size = _size;
    double scrollHeight = size.height - padding.top - padding.bottom;

    if (prevChapter[1] != 0 && prevChapter[1] < scrollHeight) prevChapter[1] = scrollHeight;
    if (currentChapter[1] != 0 && currentChapter[1] < scrollHeight) currentChapter[1] = scrollHeight;
    if (nextChapter[1] != 0 && nextChapter[1] < scrollHeight) nextChapter[1] = scrollHeight;

    if (currentChapter[0] != null && controller.initialPage != null) {
      controller.scrollTo((controller.initialPage * scrollHeight).clamp(0.0, currentChapter[1] - scrollHeight));
    }

    if (controller.jumpToEnd >= 0) {
      controller.scrollTo(currentChapter[1] - (controller.jumpToEnd == 0 ? -controller.scrollOffset : controller.jumpToEnd));
      if (!inLoading) {
        controller.jumpToEnd = -1;
      }
    }

    if (!inLoading && currentChapter[0] == null) {
      controller.scrollTo(0);
    }

    int milliseconds = DateTime.now().millisecondsSinceEpoch;

    if (beginTouchPoint != null && touchPoint != null && !inLoading) {
      controller.lastTouchPoint ??= beginTouchPoint;
      controller.scroll(controller.lastTouchPoint.dy - touchPoint.dy);
      if (controller.lastTouchMilliseconds != null) {
        controller.velocity = (controller.lastTouchPoint.dy - touchPoint.dy) /
          (milliseconds - controller.lastTouchMilliseconds) * 1000;
      }
    } else {
      if (beginTouchPoint == null && touchPoint == null
          && controller.velocity != null && !inLoading) {
        controller.startMotion();
      }
      if (inLoading) {
        controller.stopMotion();
      }
      controller.lastTouchPoint = null;
      controller.lastTouchMilliseconds = null;
      controller.velocity = null;
    }

    if (touchPoint != null) {
      controller.lastTouchPoint = touchPoint;
      controller.lastTouchMilliseconds = milliseconds;
    }

    double scrollOffsetAfterPaint;

    if (!inLoading) {
      if (controller.scrollOffset < 0) {
        if (prevChapter[1] != 0) {
          if (currentChapter[0] == null) {
            controller.stopMotion();
            controller.scrollTo(0);
            controller.jumpToEnd = scrollHeight;
            toPrevChapter();
          } else {
            if (prevChapter[0] == null) {
              controller.stopMotion();
              controller.scrollTo(0);
              loadPrevChapter();
            } else {
              controller.jumpToEnd = 0;
              toPrevChapter();
            }
          }
        } else {
          controller.stopMotion();
          controller.scrollTo(0);
        }
      } else if (controller.scrollOffset >= currentChapter[1]) {
        scrollOffsetAfterPaint = controller.scrollOffset - currentChapter[1];
        toNextChapter();
      } else if (controller.scrollOffset > currentChapter[1] - scrollHeight) {
        if (nextChapter[1] == 0) {
          controller.stopMotion();
          controller.scrollTo(currentChapter[1] - scrollHeight);
        } else {
          if (currentChapter[0] == null) {
            controller.stopMotion();
            controller.scrollTo(currentChapter[1] - scrollHeight);
            scrollOffsetAfterPaint = 0;
            toNextChapter();
          } else {
            if (nextChapter[0] == null) {
              controller.stopMotion();
              controller.scrollTo(currentChapter[1] - scrollHeight);
              loadNextChapter();
            }
          }
        }
      }
    }

    if (controller.initialPage == null) {
      double pageOffset = controller.scrollOffset.clamp(0.0, currentChapter[1]);
      int page = pageOffset ~/ scrollHeight;

      if (page != controller.page) {
        controller.page = page;
        onPageChange(page);
      }
    }

    double scrollOffset = prevChapter[1] + controller.scrollOffset;

    canvas.drawColor(background, BlendMode.src);
    canvas.clipPath(Path()
      ..moveTo(padding.left, padding.top)
      ..lineTo(size.width - padding.right, padding.top)
      ..lineTo(size.width - padding.right, size.height - padding.bottom)
      ..lineTo(padding.left, size.height - padding.bottom)
      ..close());

    canvas.save();
    canvas.translate(0, padding.top - scrollOffset);
    if (prevChapter[0] != null) canvas.drawPicture(prevChapter[0]);
    canvas.translate(0, prevChapter[1]);
    if (currentChapter[0] != null) canvas.drawPicture(currentChapter[0]);
    canvas.translate(0, currentChapter[1]);
    if (nextChapter[0] != null) canvas.drawPicture(nextChapter[0]);
    canvas.restore();

    if (scrollOffsetAfterPaint != null) controller.scrollTo(scrollOffsetAfterPaint);
  }

  @override
  bool shouldRepaint(RollPageTurningPainter oldDelegate) {
    return beginTouchPoint != oldDelegate.beginTouchPoint
      || touchPoint != oldDelegate.touchPoint
      || inLoading != oldDelegate.inLoading
      || controller != oldDelegate.controller
      || padding != oldDelegate.padding
      || background != oldDelegate.background
      || prevChapter != oldDelegate.prevChapter
      || currentChapter != oldDelegate.currentChapter
      || nextChapter != oldDelegate.nextChapter
      || toNextChapter != oldDelegate.toNextChapter
      || toPrevChapter != oldDelegate.toPrevChapter
      || loadNextChapter != oldDelegate.loadNextChapter
      || onPageChange != oldDelegate.onPageChange;
  }
}