import 'package:flutter/material.dart';

/// Token warna LAZY — sumber: DESIGN_SYSTEM.md §3.
abstract final class AppColors {
  // Base palette
  static const warmIvory = Color(0xFFF7F5EF);
  static const nearBlack = Color(0xFF20211F);
  static const butterYellow = Color(0xFFF2D66D);
  static const softSage = Color(0xFFA9B9A0);
  static const neutralGray = Color(0xFFE7E5DF);

  // Semantic (light mode)
  static const bg = warmIvory;
  static const surface = Color(0xFFFDFCFB);
  static const surfaceElevated = Color(0xFFFFFFFF);
  static const textPrimary = nearBlack;
  static const textSecondary = Color(0xFF4A4B45);
  static const textDisabled = Color(0xFF8B8C87);
  static const primary = butterYellow;
  static const onPrimary = nearBlack;
  static const secondary = softSage;
  static const onSecondary = nearBlack;
  static const accent = butterYellow;
  static const border = neutralGray;
  static const divider = Color(0xFFEDEBE7);
  static const success = Color(0xFF6B8A5A);
  static const warning = Color(0xFFB9A06C);
  static const error = Color(0xFFD16B6B);
  static const focus = Color(0xFFC9B05F);
  static const selected = Color(0xFFF5E7B8);
  static const pressed = Color(0xFFE9D08A);
}
