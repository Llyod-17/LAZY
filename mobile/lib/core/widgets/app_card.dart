import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Kartu flat 12px radius, surface `#FDFCFB`, border subtle — DESIGN_SYSTEM.md §6.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: selected ? AppColors.selected : AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: selected ? AppColors.focus : AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: card,
    );
  }
}
