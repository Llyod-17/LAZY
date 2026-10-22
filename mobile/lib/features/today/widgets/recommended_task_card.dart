import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../lazy_engine/lazy_engine.dart';
import '../../tasks/providers/task_providers.dart';

/// Kartu rekomendasi: task terpilih + alasan + aksi Kerjakan / Saran Lain.
class RecommendedTaskCard extends ConsumerWidget {
  const RecommendedTaskCard({
    super.key,
    required this.recommendation,
    required this.onSuggestAnother,
  });

  final RecommendationResult recommendation;
  final VoidCallback onSuggestAnother;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      selected: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Text('Saran untukmu', style: text.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recommendation.taskTitle,
            style: text.headlineSmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            recommendation.reason,
            style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Kerjakan',
                  icon: Icons.play_arrow,
                  onTap: () {
                    ref.read(taskActionsProvider.notifier).start(recommendation.taskId);
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(content: Text('Oke, kerjakan pelan-pelan ya')),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: onSuggestAnother,
                child: const Text('Saran Lain'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
