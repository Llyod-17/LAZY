import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Chip status task — warna dari token semantic — DESIGN_SYSTEM.md §6.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.status = TaskStatus.todo,
  });

  final String label;
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      TaskStatus.todo => (AppColors.surface, AppColors.textSecondary),
      TaskStatus.inProgress => (AppColors.selected, AppColors.textPrimary),
      TaskStatus.done => (AppColors.softSage, AppColors.nearBlack),
      TaskStatus.overdue => (AppColors.error, AppColors.surfaceElevated),
      TaskStatus.someday => (AppColors.neutralGray, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pillAll),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum TaskStatus { todo, inProgress, done, overdue, someday }
