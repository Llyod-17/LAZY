import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/task_providers.dart';

/// Kartu satu task: checkbox complete/reopen, judul (strike-through saat done),
/// deadline, prioritas. Tap → detail.
class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = task.status == 'completed';
    final text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/task/${task.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Checkbox(
                value: completed,
                shape: const CircleBorder(),
                onChanged: (_) {
                  final actions = ref.read(taskActionsProvider.notifier);
                  completed
                      ? actions.reopen(task.id)
                      : actions.complete(task.id);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: text.bodyLarge?.copyWith(
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: completed
                            ? AppColors.textDisabled
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (task.deadlineAt != null)
                          _DeadlineLabel(ms: task.deadlineAt!),
                        _PriorityChip(priority: task.priority),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineLabel extends StatelessWidget {
  const _DeadlineLabel({required this.ms});

  final int ms;

  @override
  Widget build(BuildContext context) {
    final local = DateTime.fromMillisecondsSinceEpoch(
      ms,
      isUtc: true,
    ).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final label = day == today
        ? 'Hari ini, ${DateFormat('HH:mm').format(local)}'
        : DateFormat('d MMM, HH:mm').format(local);
    return Text(label, style: Theme.of(context).textTheme.bodySmall);
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'high' => ('Tinggi', AppColors.error),
      'medium' => ('Sedang', AppColors.warning),
      _ => ('Rendah', AppColors.success),
    };
    // Non-color indicator: teks label selalu ikut (DESIGN_SYSTEM §13).
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
