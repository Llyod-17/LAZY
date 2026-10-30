import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../lazy_engine/lazy_engine.dart';
import '../providers/energy_providers.dart';

/// Chips pilih level energi — dipakai di Today dashboard (DESIGN_SYSTEM §6).
class EnergySelector extends ConsumerWidget {
  const EnergySelector({super.key});

  static const _labels = {
    EnergyLevel.low: 'Rendah',
    EnergyLevel.medium: 'Sedang',
    EnergyLevel.high: 'Tinggi',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current =
        ref.watch(currentEnergyProvider).value ?? EnergyLevel.medium;

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final level in EnergyLevel.values)
          ChoiceChip(
            key: Key('energy-${level.name}'),
            label: Text(_labels[level]!),
            selected: current == level,
            showCheckmark: false,
            selectedColor: AppColors.selected,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: current == level
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
            onSelected: (_) =>
                ref.read(energyRepositoryProvider).setEnergy(level),
          ),
      ],
    );
  }
}
