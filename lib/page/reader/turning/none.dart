import 'package:flutter/material.dart';
import 'dart:ui';
import 'page_turning.dart';

class NonePageTurningPainter extends PageTurningPainter {
  final Color background;
  final Picture currentPage;

  @override
  bool get isAnimEnd => true;

  NonePageTurningPainter({
    @required this.background,
    @required this.currentPage,
  });

  @override
  void paint(Canvas _canvas, Size _size) {
    canvas = _canvas;
    size = _size;

    if (background != null) canvas.drawColor(background, BlendMode.src);
    if (currentPage != null) canvas.drawPicture(currentPage);
  }

  @override
  bool shouldRepaint(NonePageTurningPainter oldDelegate) {
    return background != oldDelegate.background
      || currentPage != oldDelegate.currentPage;
  }
}