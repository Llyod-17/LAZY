import 'package:flutter/material.dart';

/// Skala spacing 4-pt — sumber: DESIGN_SYSTEM.md §5.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double xxxx = 48;

  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets card = EdgeInsets.all(base);
}
