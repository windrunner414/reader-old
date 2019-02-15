import 'package:flutter/material.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'dart:ui';

class CoveragePageTurningPainter extends PageTurningPainter {
  final Offset beginTouchPoint, touchPoint;
  final bool toPrev;
  final Color background;
  final Picture prevPage, currentPage, nextPage;

  double get _dx => toPrev ? touchPoint.dx - beginTouchPoint.dx : size.width - beginTouchPoint.dx + touchPoint.dx;
  @override
  bool get isAnimEnd => (touchPoint == null || beginTouchPoint == null || size == null) ? false : (_dx < -5 || _dx > size.width);

  static final shadow = Shadow(color: const Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 5).toPaint();

  CoveragePageTurningPainter({
    @required this.beginTouchPoint,
    @required this.touchPoint,
    @required this.toPrev,
    @required this.background,
    @required this.prevPage,
    @required this.currentPage,
    @required this.nextPage,
  });

  @override
  void paint(Canvas _canvas, Size _size) {
    canvas = _canvas;
    size = _size;

    if (background != null) canvas.drawColor(background, BlendMode.src);
    if (touchPoint == null || beginTouchPoint == null) {
      if (currentPage != null) canvas.drawPicture(currentPage);
      return;
    }

    double dx = _dx;
    if (dx > size.width) dx = size.width;

    canvas.clipPath(Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close());

    Path pathA = Path()
      ..lineTo(dx, 0)
      ..lineTo(dx, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path pathB = Path()
      ..moveTo(dx, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(dx, size.height)
      ..close();

    Path pathShadow = Path()
      ..moveTo(dx, 0)
      ..lineTo(dx + 5, 0)
      ..lineTo(dx + 5, size.height)
      ..lineTo(dx, size.height)
      ..close();

    if (toPrev) {
      canvas.save();
      canvas.clipPath(pathB);
      if (currentPage != null) canvas.drawPicture(currentPage);
      canvas.drawPath(pathShadow, shadow);
      canvas.restore();

      if (prevPage != null) {
        canvas.save();
        canvas.clipPath(pathA);
        canvas.translate(dx - size.width, 0);
        canvas.drawPicture(prevPage);
        canvas.restore();
      }
    } else {
      if (currentPage != null) {
        canvas.save();
        canvas.clipPath(pathA);
        canvas.translate(dx - size.width, 0);
        canvas.drawPicture(currentPage);
        canvas.restore();
      }

      canvas.save();
      canvas.clipPath(pathB);
      if (nextPage != null) canvas.drawPicture(nextPage);
      canvas.drawPath(pathShadow, shadow);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CoveragePageTurningPainter oldDelegate) {
    return beginTouchPoint != oldDelegate.beginTouchPoint
      || touchPoint != oldDelegate.touchPoint
      || toPrev != oldDelegate.toPrev
      || background != oldDelegate.background
      || prevPage != oldDelegate.prevPage
      || currentPage != oldDelegate.currentPage
      || nextPage != oldDelegate.nextPage;
  }
}