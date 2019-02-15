import 'package:flutter/material.dart';

export 'coverage.dart';
export 'simulation.dart';
export 'roll.dart';

abstract class PageTurningPainter extends CustomPainter {
  Size size;
  Canvas canvas;
  bool get painted;
  bool get isAnimEnd;
}