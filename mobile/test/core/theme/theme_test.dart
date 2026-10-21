import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/theme/app_colors.dart';
import 'package:lazy_app/core/theme/app_radius.dart';
import 'package:lazy_app/core/theme/app_spacing.dart';
import 'package:lazy_app/core/theme/app_theme.dart';
import 'package:lazy_app/core/theme/app_typography.dart';

void main() {
  group('AppColors', () {
    test('semantic colors match DESIGN_SYSTEM §3', () {
      expect(AppColors.bg, const Color(0xFFF7F5EF));
      expect(AppColors.surface, const Color(0xFFFDFCFB));
      expect(AppColors.surfaceElevated, const Color(0xFFFFFFFF));
      expect(AppColors.textPrimary, const Color(0xFF20211F));
      expect(AppColors.textSecondary, const Color(0xFF4A4B45));
      expect(AppColors.primary, const Color(0xFFF2D66D));
      expect(AppColors.onPrimary, const Color(0xFF20211F));
      expect(AppColors.secondary, const Color(0xFFA9B9A0));
      expect(AppColors.error, const Color(0xFFD16B6B));
      expect(AppColors.success, const Color(0xFF6B8A5A));
      expect(AppColors.divider, const Color(0xFFEDEBE7));
    });
  });

  group('AppSpacing', () {
    test('4-pt scale', () {
      expect(AppSpacing.xs, 4);
      expect(AppSpacing.sm, 8);
      expect(AppSpacing.md, 12);
      expect(AppSpacing.base, 16);
      expect(AppSpacing.lg, 20);
      expect(AppSpacing.xl, 24);
      expect(AppSpacing.xxl, 32);
      expect(AppSpacing.xxxl, 40);
      expect(AppSpacing.xxxx, 48);
    });
  });

  group('AppRadius', () {
    test('radius scale', () {
      expect(AppRadius.xs, 4);
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 12);
      expect(AppRadius.lg, 16);
      expect(AppRadius.xl, 20);
      expect(AppRadius.pill, 999);
    });
  });

  group('AppTypography', () {
    test('type scale sizes', () {
      final t = AppTypography.textTheme();
      expect(t.displayLarge!.fontSize, 36);
      expect(t.headlineLarge!.fontSize, 28);
      expect(t.headlineMedium!.fontSize, 24);
      expect(t.titleLarge!.fontSize, 20);
      expect(t.titleMedium!.fontSize, 18);
      expect(t.bodyLarge!.fontSize, 16);
      expect(t.bodyMedium!.fontSize, 14);
      expect(t.bodySmall!.fontSize, 12);
      expect(t.labelLarge!.fontSize, 14);
      expect(t.labelMedium!.fontSize, 12);
      expect(t.labelSmall!.fontSize, 11);
    });
  });

  group('AppTheme.light', () {
    final theme = AppTheme.light();

    test('uses Material 3', () {
      expect(theme.useMaterial3, true);
    });

    test('scaffold background is warm ivory', () {
      expect(theme.scaffoldBackgroundColor, AppColors.bg);
    });

    test('color scheme follows semantic tokens', () {
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.onPrimary, AppColors.onPrimary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.onSecondary, AppColors.onSecondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.onSurface, AppColors.textPrimary);
      expect(theme.colorScheme.error, AppColors.error);
    });

    test('card uses 12px radius and border', () {
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect((shape.borderRadius as BorderRadius).topLeft.x, AppRadius.md);
    });
  });
}
