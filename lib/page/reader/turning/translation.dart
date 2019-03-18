import 'package:flutter/material.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'dart:ui';

class TranslationPageTurningPainter extends PageTurningPainter {
  final Offset beginTouchPoint, touchPoint;
  final bool toPrev;
  final Color background;
  final Picture prevPage, currentPage, nextPage;

  double get _dx => toPrev ? touchPoint.dx - beginTouchPoint.dx - size.width : touchPoint.dx - beginTouchPoint.dx;
  @override
  bool get isAnimEnd => (touchPoint == null || beginTouchPoint == null || size == null) ? false : (_dx < -size.width || _dx > 0);

  TranslationPageTurningPainter({
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

    double dx = _dx.clamp(-size.width, 0.0);

    canvas.clipPath(Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close());

    if (toPrev) {
      canvas.save();
      canvas.translate(dx, 0);
      if (prevPage != null) canvas.drawPicture(prevPage);
      canvas.translate(size.width, 0);
      if (currentPage != null) canvas.drawPicture(currentPage);
      canvas.restore();
    } else {
      canvas.save();
      canvas.translate(dx, 0);
      if (currentPage != null) canvas.drawPicture(currentPage);
      canvas.translate(size.width, 0);
      if (nextPage != null) canvas.drawPicture(nextPage);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TranslationPageTurningPainter oldDelegate) {
    return beginTouchPoint != oldDelegate.beginTouchPoint
      || touchPoint != oldDelegate.touchPoint
      || toPrev != oldDelegate.toPrev
      || background != oldDelegate.background
      || prevPage != oldDelegate.prevPage
      || currentPage != oldDelegate.currentPage
      || nextPage != oldDelegate.nextPage;
  }
}