import 'package:flutter/material.dart';
import 'dart:ui';

List pagination({
  @required String content,
  @required double fontSize,
  String fontFamily,
  @required FontWeight fontWeight,
  @required Color color,
  @required double height,
  @required double paragraphHeight,
  @required Size size,
  @required EdgeInsets padding,
  @required bool isRoll,
}) {
  if (paragraphHeight != null) {
    content = content.replaceAll("\n", "\n" * paragraphHeight.round());
  }

  TextStyle textStyle = TextStyle(
    fontSize: fontSize,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    height: height,
    color: color,
  );

  StrutStyle strutStyle = StrutStyle(
    fontSize: fontSize,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    height: height,
    forceStrutHeight: true,
  );

  TextSpan textSpan = TextSpan(
    text: content,
    style: textStyle,
  );

  TextPainter textPainter = TextPainter(
    text: textSpan,
    strutStyle: strutStyle,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: size.width - padding.left - padding.right);

  if (isRoll) {
    List page = List(3);
    PictureRecorder pictureRecorder = PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    textPainter.paint(canvas, Offset(padding.left, padding.top));

    page[0] = pictureRecorder.endRecording();
    page[1] = textPainter.height.clamp(size.height, double.infinity);
    page[2] = (page[1] / size.height).ceil();

    return page;
  } else {
    double textHeight = textPainter.height;
    double lineHeight = textPainter.preferredLineHeight;
    double pageHeight = size.height - padding.top - padding.bottom;
    int lineNumber = textHeight ~/ lineHeight;
    int lineNumberPerPage = pageHeight ~/ lineHeight;
    int pageNum = (lineNumber / lineNumberPerPage).ceil();
    double actualPageHeight = lineNumberPerPage * lineHeight;

    List<Picture> pages = List<Picture>(pageNum);
    for (int i = 0; i < pageNum; ++i) {
      PictureRecorder pictureRecorder = PictureRecorder();
      Canvas canvas = Canvas(pictureRecorder);
      canvas.clipPath(Path()
        ..moveTo(padding.left, padding.top)
        ..lineTo(size.width - padding.right, padding.top)
        ..lineTo(size.width - padding.right, padding.top + actualPageHeight)
        ..lineTo(padding.left, padding.top + actualPageHeight)
        ..close());
      canvas.translate(padding.left, -i * actualPageHeight + padding.top);
      textPainter.paint(canvas, Offset(0, 0));
      pages[i] = pictureRecorder.endRecording();
    }

    return pages;
  }
}