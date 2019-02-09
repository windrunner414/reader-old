import 'package:flutter/material.dart';
import 'package:reader/page/reader/turning/page_turning.dart';
import 'dart:ui';

class CoveragePageTurning extends PageTurningPainter {
  final Offset touchPoint;
  final bool toPrev;
  final Color background;
  final Picture prevPage, currentPage, nextPage;
  Size size;
  Canvas canvas;
  bool get painted => size != null;

  static final shadow = Shadow(color: const Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 5).toPaint();

  CoveragePageTurning({
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
    if (touchPoint == null) {
      if (currentPage != null) canvas.drawPicture(currentPage);
      return;
    }

    canvas.clipPath(Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close());

    Path pathA = Path()
      ..lineTo(touchPoint.dx, 0)
      ..lineTo(touchPoint.dx, size.height)
      ..lineTo(0, size.height)
      ..close();

    Path pathB = Path()
      ..moveTo(touchPoint.dx, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(touchPoint.dx, size.height)
      ..close();

    Path pathShadow = Path()
      ..moveTo(touchPoint.dx, 0)
      ..lineTo(touchPoint.dx + 5, 0)
      ..lineTo(touchPoint.dx + 5, size.height)
      ..lineTo(touchPoint.dx, size.height)
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
        canvas.translate(touchPoint.dx - size.width, 0);
        canvas.drawPicture(prevPage);
        canvas.restore();
      }
    } else {
      if (currentPage != null) {
        canvas.save();
        canvas.clipPath(pathA);
        canvas.translate(touchPoint.dx - size.width, 0);
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
  bool shouldRepaint(CoveragePageTurning oldDelegate) {
    return touchPoint != oldDelegate.touchPoint
      || toPrev != oldDelegate.toPrev
      || background != oldDelegate.background
      || prevPage != oldDelegate.prevPage
      || currentPage != oldDelegate.currentPage
      || nextPage != oldDelegate.nextPage;
  }
}