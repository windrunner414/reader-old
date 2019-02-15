import 'package:flutter/material.dart';

export 'coverage.dart';
export 'simulation.dart';
export 'roll.dart';
export 'none.dart';

abstract class PageTurningPainter extends CustomPainter {
  Size size;
  Canvas canvas;
  bool get painted => size != null && canvas != null;
  bool get isAnimEnd;
}