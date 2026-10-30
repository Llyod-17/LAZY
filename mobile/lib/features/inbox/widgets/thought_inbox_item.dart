import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';

/// Kartu untuk satu ide di Thought Inbox.
class ThoughtInboxItem extends StatelessWidget {
  const ThoughtInboxItem({
    super.key,
    required this.thought,
    required this.onConvertToTask,
    required this.onDelete,
  });

  final ThoughtInboxData thought;
  final VoidCallback onConvertToTask;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(thought.title, style: text.titleMedium)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error,
                  tooltip: 'Hapus ide',
                  onPressed: onDelete,
                ),
              ],
            ),
            if (thought.content != null && thought.content!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                thought.content!,
                style: text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Jadikan Kegiatan',
              icon: Icons.arrow_forward,
              variant: AppButtonVariant.primary,
              onTap: onConvertToTask,
            ),
          ],
        ),
      ),
    );
  }
}
