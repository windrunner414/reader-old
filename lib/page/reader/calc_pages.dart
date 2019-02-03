import 'package:flutter/material.dart';
import 'dart:ui';

TextPainter _getTextPainter(TextSpan text, Size size, EdgeInsets padding) {
  return TextPainter(
    textDirection: TextDirection.ltr,
    text: text,
  )..layout(maxWidth: size.width - padding.left - padding.right);
}

bool _isHeightEnough(TextSpan text, Size size, EdgeInsets padding) {
  TextPainter painter = _getTextPainter(text, size, padding);

  if (painter.height <= size.height - padding.top - padding.bottom) {
    return true;
  } else {
    return false;
  }
}

Picture _getPicture(TextSpan text, Size size, EdgeInsets padding) {
  TextPainter painter = _getTextPainter(text, size, padding);
  PictureRecorder pictureRecorder = PictureRecorder();
  Canvas canvas = Canvas(pictureRecorder);
  painter.paint(canvas, Offset(padding.left, padding.top));
  return pictureRecorder.endRecording();
}

List<Picture> calcPages({
  @required String content,
  @required double fontSize,
  String fontFamily,
  @required FontWeight fontWeight,
  @required Color color,
  @required double height,
  @required int paragraphHeight,
  @required Size size,
  @required EdgeInsets padding,
}) {
  content = content.replaceAll("\n", "\n" * paragraphHeight);
  TextStyle style = TextStyle(
    fontSize: fontSize,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    height: height,
    color: color,
  );
  List<Picture> pages = [];
  int tBegin = 0;

  while (tBegin < content.length) {
    if (content[tBegin] == "\n") {
      ++tBegin;
      continue;
    }

    int begin = tBegin, end = content.length;

    while (begin != end) {
      int curr = (begin + end) ~/ 2;
      if (begin == curr) curr = end;

      if (_isHeightEnough(TextSpan(
        text: content.substring(tBegin, curr),
        style: style,
      ), size, padding)) {
        begin = curr;
      } else {
        end = curr - 1;
      }
    }

    pages.add(_getPicture(TextSpan(
      text: content.substring(tBegin, begin),
      style: style,
    ), size, padding));

    tBegin = begin;
  }

  return pages;
}