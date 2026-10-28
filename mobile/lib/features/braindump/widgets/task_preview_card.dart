import 'package:flutter/material.dart';

import '../../../core/network/ai_api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

/// Kartu untuk meninjau dan mengedit satu tugas hasil ekstraksi AI sebelum disimpan.
class TaskPreviewCard extends StatelessWidget {
  const TaskPreviewCard({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  final ExtractedTask task;
  final ValueChanged<ExtractedTask> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isUnscheduled = task.suggestedDate == null || task.suggestedDate!.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: task.title,
                    decoration: const InputDecoration(
                      labelText: 'Judul Tugas',
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                    style: textTheme.titleMedium,
                    onChanged: (val) {
                      onChanged(
                        ExtractedTask(
                          title: val,
                          suggestedDate: task.suggestedDate,
                          suggestedTime: task.suggestedTime,
                          priority: task.priority,
                          reason: task.reason,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Hapus item',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isUnscheduled)
                  Chip(
                    label: const Text('Unscheduled (ke Inbox)'),
                    backgroundColor: AppColors.neutralGray,
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else ...[
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(task.suggestedDate!),
                    backgroundColor: AppColors.selected,
                    labelStyle: textTheme.labelSmall,
                  ),
                  if (task.suggestedTime != null && task.suggestedTime!.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.access_time, size: 14),
                      label: Text(task.suggestedTime!),
                      backgroundColor: AppColors.warmIvory,
                      labelStyle: textTheme.labelSmall,
                    ),
                ],
                if (task.priority != null && task.priority!.isNotEmpty)
                  Chip(
                    label: Text('Prioritas: ${task.priority}'),
                    backgroundColor: AppColors.warmIvory,
                    labelStyle: textTheme.labelSmall,
                  ),
              ],
            ),
            if (task.reason != null && task.reason!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Alasan AI: ${task.reason}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
