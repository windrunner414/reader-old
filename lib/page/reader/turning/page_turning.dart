import 'package:flutter/material.dart';

abstract class PageTurningPainter extends CustomPainter {
  Size size;
  Canvas canvas;
  bool get painted;
}