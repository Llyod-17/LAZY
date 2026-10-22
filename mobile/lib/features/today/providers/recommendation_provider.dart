import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../energy/providers/energy_providers.dart';
import '../../lazy_engine/lazy_engine.dart';
import '../../tasks/providers/task_providers.dart';

CandidateTask candidateFromTask(Task task) {
  return CandidateTask(
    id: task.id,
    title: task.title,
    status: task.status,
    priority: task.priority,
    createdAt: DateTime.fromMillisecondsSinceEpoch(task.createdAt, isUtc: true).toLocal(),
    deadlineAt: task.deadlineAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(task.deadlineAt!, isUtc: true).toLocal(),
    estimatedDurationMin: task.estimatedDurationMin,
    energyAffinity: task.energyAffinity,
  );
}

/// Ranking penuh: panggil engine berulang, buang pemenang tiap putaran.
/// ponytail: O(n²) cukup untuk daftar lokal (<200 task); ganti satu-pass sort
/// hanya kalau engine dipakai offline untuk dataset besar.
List<RecommendationResult> rankTasks(
  List<Task> tasks,
  EnergyLevel energy,
  DateTime now,
) {
  final remaining = tasks.map(candidateFromTask).toList();
  final ranked = <RecommendationResult>[];
  while (remaining.isNotEmpty) {
    final result = computeRecommendation(remaining, energy, now);
    if (result == null) break;
    ranked.add(result);
    remaining.removeWhere((c) => c.id == result.taskId);
  }
  return ranked;
}

class RecommendationState {
  const RecommendationState({this.ranked = const [], this.index = 0});

  final List<RecommendationResult> ranked;
  final int index;

  RecommendationResult? get current =>
      ranked.isEmpty ? null : ranked[index % ranked.length];
}

class RecommendationNotifier extends Notifier<RecommendationState> {
  @override
  RecommendationState build() {
    final tasks = ref.watch(todayTasksStreamProvider).value ?? const <Task>[];
    final energy = ref.watch(currentEnergyProvider).value ?? EnergyLevel.medium;
    return RecommendationState(ranked: rankTasks(tasks, energy, DateTime.now()));
  }

  /// "Saran Lain": putar ke kandidat berikutnya.
  void suggestAnother() {
    if (state.ranked.length > 1) {
      state = RecommendationState(ranked: state.ranked, index: state.index + 1);
    }
  }
}

final recommendationProvider =
    NotifierProvider<RecommendationNotifier, RecommendationState>(
  RecommendationNotifier.new,
);
