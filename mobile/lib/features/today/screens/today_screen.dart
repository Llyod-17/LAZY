import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../energy/widgets/energy_selector.dart';
import '../../tasks/providers/task_providers.dart';
import '../../tasks/widgets/task_card.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/lazy_button.dart';
import '../widgets/recommended_task_card.dart';

const _weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// ponytail: nama hari/bulan hardcode supaya tak perlu locale data intl;
/// ganti DateFormat('EEEE, d MMM', 'id_ID') kalau app jadi multi-bahasa.
String formatTodayDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

/// S02 — Today Dashboard: sapaan, energy check-in, rekomendasi, kegiatan hari ini.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _showRecommendation = false;

  void _handleLazy() {
    final recommendation = ref.read(recommendationProvider).current;
    if (recommendation == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Belum ada kegiatan hari ini. Santai dulu ya')),
      );
      return;
    }
    setState(() => _showRecommendation = true);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tasks = ref.watch(todayTasksStreamProvider).value ?? const [];
    final recommendation = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hari ini')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.base,
          AppSpacing.base,
          120,
        ),
        children: [
          Text(
            formatTodayDate(DateTime.now()),
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Mau mulai dari mana?', style: text.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Text('Energi sekarang', style: text.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          const EnergySelector(),
          const SizedBox(height: AppSpacing.lg),
          LazyButton(onPressed: _handleLazy),
          if (_showRecommendation && recommendation.current != null) ...[
            const SizedBox(height: AppSpacing.md),
            RecommendedTaskCard(
              recommendation: recommendation.current!,
              onSuggestAnother: () =>
                  ref.read(recommendationProvider.notifier).suggestAnother(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Kegiatan hari ini', style: text.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: EmptyStateView(
                icon: Icons.wb_sunny_outlined,
                title: 'Hari ini kosong',
                subtitle: 'Tidak ada kegiatan terjadwal. Nikmati saja.',
              ),
            )
          else
            ...tasks.map((task) => TaskCard(task: task)),
        ],
      ),
    );
  }
}
