import 'package:flutter/material.dart';

/// Skala border radius — sumber: DESIGN_SYSTEM.md §5.
abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static final BorderRadius card = BorderRadius.circular(md);
  static final BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  static final BorderRadius pillAll = BorderRadius.circular(pill);
}
