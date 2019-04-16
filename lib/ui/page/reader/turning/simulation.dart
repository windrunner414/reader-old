import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'page_turning.dart';

enum _AnimType {
  LEFT,
  RIGHT_TOP,
  RIGHT_MIDDLE,
  RIGHT_BOTTOM,
}

class SimulationPageTurningPainter extends PageTurningPainter {
  Offset a, b, c, d, e, f, g, h, i, j, k;
  final Offset beginTouchPoint, touchPoint;
  final Picture prevPage, currentPage, nextPage;
  final Color background;
  final bool toPrev;

  @override
  bool get isAnimEnd => (_pathA == null || _pathC == null) ? false : (
    (_pathA.contains(Offset(0, 0)) && _pathA.contains(Offset(size.width, 0))
      && _pathA.contains(Offset(0, size.height)) && _pathA.contains(Offset(size.width, size.height)))
    || (_pathC.contains(Offset(0, 0)) && _pathC.contains(Offset(size.width, 0))
        && _pathC.contains(Offset(0, size.height)) && _pathC.contains(Offset(size.width, size.height)))
  );

  _AnimType _type;
  Path _pathAll, _pathA, _pathB, _pathC, _pathD;

  static final _shadow1Paint1 = Shadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8).toPaint();
  static final _shadow1Paint2 = Shadow(color: Color.fromRGBO(0, 0, 0, 0.5), blurRadius: 8).toPaint();
  static final _shadow2Paint1 = Shadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 15).toPaint();
  static final _shadow2Paint2 = Shadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 20).toPaint();

  SimulationPageTurningPainter({
    @required this.beginTouchPoint,
    @required this.touchPoint,
    @required this.prevPage,
    @required this.currentPage,
    @required this.nextPage,
    @required this.toPrev,
    @required this.background,
  });

  Offset _calcPointA(Offset ap) {
    if (_type == _AnimType.RIGHT_MIDDLE || _type == _AnimType.LEFT) {
      return Offset(ap.dx, size.height / 2 - 0.1);
    }

    return ap;
  }

  void _calcPointAByTouchPoint() {
    double w0 = size.width - c.dx;

    double w1 = f.dx - a.dx;
    if (w1 < 0) w1 = -w1;
    double w2 = size.width * w1 / w0;
    double ax = f.dx - w2;
    if (ax < 0) ax = -ax;

    double h1 = f.dy - a.dy;
    if (h1 < 0) h1 = -h1;
    double h2 = w2 * h1 / w1;
    double ay = f.dy - h2;
    if (ay < 0) ay = -ay;

    a = _calcPointA(Offset(ax, ay));
  }

  void _calcPointXY() {
    g = Offset((a.dx + f.dx) / 2, (a.dy + f.dy) / 2);
    e = Offset(g.dx - (f.dy - g.dy) * (f.dy - g.dy) / (f.dx - g.dx), f.dy);
    h = Offset(f.dx, (g.dy - (f.dx - g.dx) * (f.dx - g.dx) / (f.dy - g.dy)));
    c = Offset(e.dx - (f.dx - e.dx) / 2, f.dy);
    j = Offset(f.dx, h.dy - (f.dy - h.dy) / 2);
    b = _getIntersectionPoint(a, e, c, j);
    k = _getIntersectionPoint(a, h, c, j);
    d = Offset((c.dx + 2 * e.dx + b.dx) / 4, (c.dy + 2 * e.dy + b.dy) / 4);
    i = Offset((j.dx + 2 * h.dx + k.dx) / 4, (j.dy + 2 * h.dy + k.dy) / 4);
  }

  Offset _getIntersectionPoint(
    Offset lineOnePointOne, Offset lineOnePointTwo,
    Offset lineTwoPointOne, Offset lineTwoPointTwo,
  ) {
    double x1, y1, x2, y2, x3, y3, x4, y4;
    x1 = lineOnePointOne.dx;
    y1 = lineOnePointOne.dy;
    x2 = lineOnePointTwo.dx;
    y2 = lineOnePointTwo.dy;
    x3 = lineTwoPointOne.dx;
    y3 = lineTwoPointOne.dy;
    x4 = lineTwoPointTwo.dx;
    y4 = lineTwoPointTwo.dy;

    double pointX =((x1 - x2) * (x3 * y4 - x4 * y3) - (x3 - x4) * (x1 * y2 - x2 * y1))
        / ((x3 - x4) * (y1 - y2) - (x1 - x2) * (y3 - y4));
    double pointY =((y1 - y2) * (x3 * y4 - x4 * y3) - (x1 * y2 - x2 * y1) * (y3 - y4))
        / ((y1 - y2) * (x3 - x4) - (x1 - x2) * (y3 - y4));

    return Offset(pointX, pointY);
  }

  void _calcPoint() {
    if (toPrev) {
      _type = _AnimType.LEFT;
      f = Offset(size.width, size.height / 2);
    } else {
      if (beginTouchPoint.dy < size.height / 3) {
        _type = _AnimType.RIGHT_TOP;
        f = Offset(size.width, 0);
      } else if (beginTouchPoint.dy >= size.height / 3 &&
          beginTouchPoint.dy < size.height / 3 * 2) {
        _type = _AnimType.RIGHT_MIDDLE;
        f = Offset(size.width, size.height / 2);
      } else {
        _type = _AnimType.RIGHT_BOTTOM;
        f = Offset(size.width, size.height);
      }
    }

    a = _calcPointA(touchPoint);
    _calcPointXY();

    if (c.dx < 0 && a.dx >= 0 && a.dx <= size.width && a.dy >= 0 && a.dy <= size.height) {
      _calcPointAByTouchPoint();
      _calcPointXY();
    }
  }

  void _calcPath() {
    _pathAll = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    switch (_type) {
      case _AnimType.RIGHT_BOTTOM:
        _pathA = Path()
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(c.dx, c.dy)
          ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy)
          ..lineTo(a.dx, a.dy)
          ..lineTo(k.dx, k.dy)
          ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy)
          ..lineTo(size.width, 0)
          ..close();
        break;
      case _AnimType.LEFT:
      case _AnimType.RIGHT_MIDDLE:
        _pathA = Path()
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(a.dx, size.height)
          ..lineTo(a.dx, 0)
          ..close();
        break;
      case _AnimType.RIGHT_TOP:
        _pathA = Path()
          ..moveTo(0, 0)
          ..lineTo(0, size.height)
          ..lineTo(size.width, size.height)
          ..lineTo(j.dx, j.dy)
          ..quadraticBezierTo(h.dx, h.dy, k.dx, k.dy)
          ..lineTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..quadraticBezierTo(e.dx, e.dy, c.dx, c.dy)
          ..close();
        break;
      default:
        break;
    }

    if (_type == _AnimType.RIGHT_MIDDLE || _type == _AnimType.LEFT) {
      _pathB = Path()
        ..moveTo(a.dx, 0)
        ..lineTo(d.dx, 0)
        ..lineTo(d.dx, size.height)
        ..lineTo(a.dx, size.height)
        ..close();
    } else {
      _pathB = Path()
        ..moveTo(d.dx, d.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(a.dx, a.dy)
        ..lineTo(k.dx, k.dy)
        ..lineTo(i.dx, i.dy)
        ..close();
    }

    _pathC = Path.combine(
      PathOperation.reverseDifference,
      Path.combine(PathOperation.union, _pathA, _pathB),
      _pathAll,
    );

    _pathD = Path.combine(
      PathOperation.reverseDifference,
      Path.combine(PathOperation.intersect, _pathA, _pathB),
      _pathB,
    );
  }

  void _drawPathA() {
    canvas.save();
    canvas.clipPath(_pathA);
    if (!toPrev && currentPage != null) {
      canvas.drawPicture(currentPage);
    } else if (toPrev && prevPage != null) {
      canvas.drawPicture(prevPage);
    }
    canvas.restore();
  }

  void _drawShadow1() {
    double shadowDis = 7;
    double afDis = sqrt((f.dx - a.dx)  * (f.dx - a.dx) + (f.dy - a.dy) * (f.dy - a.dy));
    double s = shadowDis / afDis;
    double x1 = a.dx - (size.width - a.dx) * s;
    double y1;

    switch (_type) {
      case _AnimType.RIGHT_BOTTOM:
        y1 = a.dy - (size.height - a.dy) * s;
        break;
      case _AnimType.RIGHT_TOP:
        y1 = a.dy * (1 + s);
        break;
      default:
        break;
    }

    double k1 = (a.dy - k.dy) / (a.dx - k.dx);
    double k2 = (a.dy - b.dy) / (a.dx - b.dx);

    Offset shadow1Point, shadow1Point2, shadow2Point, shadow2Point2;

    switch (_type) {
      case _AnimType.RIGHT_BOTTOM:
        shadow1Point = Offset(size.width, k1 * (size.width - x1) + y1);
        shadow1Point2 = _getIntersectionPoint(a, k, j, h);
        shadow2Point = Offset((size.height - y1) / k2 + x1, size.height);
        shadow2Point2 = _getIntersectionPoint(a, b, c, e);
        break;
      case _AnimType.RIGHT_TOP:
        shadow1Point = Offset(size.width, k1 * (size.width - x1) + y1);
        shadow1Point2 = _getIntersectionPoint(a, k, j, h);
        shadow2Point = Offset((-y1) / k2 + x1, 0);
        shadow2Point2 = _getIntersectionPoint(a, b, c, e);
        break;
      default:
        break;
    }

    canvas.save();
    canvas.clipPath(_pathA);
    if (_type == _AnimType.RIGHT_MIDDLE || _type == _AnimType.LEFT) {
      canvas.drawPath(Path()
        ..moveTo(a.dx, 0)
        ..lineTo(x1, 0)
        ..lineTo(x1, size.height)
        ..lineTo(a.dx, size.height)
        ..close(), _shadow1Paint1);
    } else {
      canvas.drawPath(Path()
        ..moveTo(x1, y1)
        ..lineTo(shadow1Point.dx, shadow1Point.dy)
        ..lineTo(shadow1Point2.dx, shadow1Point2.dy)
        ..lineTo(a.dx, a.dy)
        ..close(), _shadow1Paint1);
      canvas.drawPath(Path()
        ..moveTo(x1, y1)
        ..lineTo(shadow2Point.dx, shadow2Point.dy)
        ..lineTo(shadow2Point2.dx, shadow2Point2.dy)
        ..lineTo(a.dx, a.dy)
        ..close(), _shadow1Paint2);
    }
    canvas.restore();
  }

  void _drawPathD() {
    if (background == null) return;
    canvas.save();
    canvas.clipPath(_pathD);
    double eh = sqrt((f.dx - e.dx) * (f.dx - e.dx) + (h.dy - f.dy) * (h.dy - f.dy));
    double sin0 = (f.dx - e.dx) / eh;
    double cos0 = (h.dy - f.dy) / eh;
    var matrix3 = Matrix4.zero().getNormalMatrix()
      ..setValues(-(1 - 2 * sin0 * sin0), 2 * sin0 * cos0, 0, 2 * sin0 * cos0, 1 - 2 * sin0 * sin0, 0, 0, 0, 1.0);
    Matrix4 matrix = Matrix4.translationValues(e.dx, e.dy, 0)..setRotation(matrix3)..translate(-e.dx, -e.dy);
    canvas.transform(matrix.storage);
    if (!toPrev && currentPage != null) {
      canvas.drawPicture(currentPage);
    } else if (toPrev && prevPage != null) {
      canvas.drawPicture(prevPage);
    }
    canvas.drawColor(background.withOpacity(0.9), BlendMode.srcOver);
    canvas.restore();
  }

  void _drawShadow2() {
    Path pathShadow1, pathShadow2;

    if (_type == _AnimType.RIGHT_MIDDLE || _type == _AnimType.LEFT) {
      Offset x2 = _getIntersectionPoint(
          Offset((d.dx + e.dx) / 2, (d.dy + e.dy) / 2),
          Offset((i.dx + h.dx) / 2, (i.dy + h.dy) / 2),
          e, f);

      pathShadow1 = Path()
        ..moveTo(a.dx, 0)
        ..lineTo(a.dx, size.height)
        ..lineTo(x2.dx, size.height)
        ..lineTo(x2.dx, 0)
        ..close();

      Offset x3 = Offset((d.dx + b.dx) / 2, (d.dy + b.dy) / 2);

      pathShadow2 = Path()
        ..moveTo(d.dx, 0)
        ..lineTo(d.dx, size.height)
        ..lineTo(x3.dx, size.height)
        ..lineTo(x3.dx, 0)
        ..close();
    } else {
      Offset x2 = _getIntersectionPoint(
          Offset((d.dx + e.dx) / 2, (d.dy + e.dy) / 2),
          Offset((i.dx + h.dx) / 2, (i.dy + h.dy) / 2),
          e, f);

      Offset y2 = _getIntersectionPoint(
          Offset((d.dx + e.dx) / 2, (d.dy + e.dy) / 2),
          Offset((i.dx + h.dx) / 2, (i.dy + h.dy) / 2),
          h, f);

      pathShadow1 = Path.combine(PathOperation.intersect, Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(x2.dx, x2.dy)
        ..lineTo(y2.dx, y2.dy)
        ..lineTo(j.dx, j.dy)
        ..close(), _pathAll);

      var x3 = Offset((d.dx + b.dx) / 2, (d.dy + b.dy) / 2);
      var y3 = Offset((i.dx + k.dx) / 2, (i.dy + k.dy) / 2);

      pathShadow2 = Path.combine(PathOperation.intersect, Path()
        ..moveTo(d.dx, d.dy)
        ..lineTo(x3.dx, x3.dy)
        ..lineTo(y3.dx, y3.dy)
        ..lineTo(i.dx, i.dy)
        ..close(), _pathAll);
    }

    canvas.save();
    canvas.clipPath(_pathC);
    canvas.drawPath(pathShadow1, _shadow2Paint1);
    canvas.restore();

    canvas.save();
    canvas.clipPath(_pathD);
    canvas.drawPath(pathShadow2, _shadow2Paint2);
    canvas.restore();
  }

  void _drawPathC() {
    canvas.save();
    canvas.clipPath(_pathC);
    if (toPrev && currentPage != null) {
      canvas.drawPicture(currentPage);
    } else if (!toPrev && nextPage != null) {
      canvas.drawPicture(nextPage);
    }
    canvas.restore();
  }

  @override
  void paint(Canvas _canvas, Size _size) {
    size = _size;
    canvas = _canvas;

    if (beginTouchPoint == null || touchPoint == null) {
      if (background != null) {
        canvas.drawColor(background, BlendMode.src);
      }
      if (currentPage != null) {
        canvas.drawPicture(currentPage);
      }
      return;
    }

    _calcPoint();
    _calcPath();

    canvas.clipPath(_pathAll);
    if (background != null) {
      canvas.drawColor(background, BlendMode.src);
    }

    _drawPathA();
    _drawShadow1();
    _drawPathD();
    _drawShadow2();
    _drawPathC();
  }

  @override
  bool shouldRepaint(SimulationPageTurningPainter oldDelegate) {
    if (oldDelegate.beginTouchPoint == beginTouchPoint
      && oldDelegate.touchPoint == touchPoint
      && oldDelegate.prevPage == prevPage
      && oldDelegate.currentPage == currentPage
      && oldDelegate.nextPage == nextPage
      && oldDelegate.toPrev == toPrev
      && oldDelegate.background == background) {
      return false;
    } else {
      return true;
    }
  }
}