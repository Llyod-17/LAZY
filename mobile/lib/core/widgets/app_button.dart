import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Tombol utama LAZY: primary pill (kuning) & secondary outlined.
/// Touch target minimum 48x48 — DESIGN_SYSTEM.md §6.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? AppColors.primary : AppColors.textDisabled,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        ),
        child: content,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        ),
        child: content,
      ),
      AppButtonVariant.destructive => FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.surfaceElevated,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
        ),
        child: content,
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          minimumSize: const Size(48, 48),
        ),
        child: content,
      ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

enum AppButtonVariant { primary, secondary, destructive, ghost }
