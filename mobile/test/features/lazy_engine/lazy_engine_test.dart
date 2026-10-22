import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/features/lazy_engine/lazy_engine.dart';

void main() {
  final now = DateTime(2026, 10, 22, 9, 0);
  final createdOld = DateTime(2026, 10, 1, 9, 0);
  final createdNew = DateTime(2026, 10, 21, 9, 0);

  CandidateTask task(
    String id, {
    String status = 'pending',
    String priority = 'medium',
    DateTime? deadlineAt,
    DateTime? createdAt,
    int? duration,
    String? energy,
  }) {
    return CandidateTask(
      id: id,
      title: 'Task $id',
      status: status,
      priority: priority,
      createdAt: createdAt ?? createdOld,
      deadlineAt: deadlineAt,
      estimatedDurationMin: duration,
      energyAffinity: energy,
    );
  }

  test('empty candidates returns null', () {
    expect(computeRecommendation(const [], EnergyLevel.medium, now), isNull);
  });

  test('completed tasks are not candidates', () {
    final result = computeRecommendation(
      [task('a', status: 'completed', deadlineAt: now)],
      EnergyLevel.medium,
      now,
    );
    expect(result, isNull);
  });

  test('overdue beats due today', () {
    final overdue = task('overdue',
        deadlineAt: now.subtract(const Duration(days: 2)));
    final today = task('today', deadlineAt: now);
    final result =
        computeRecommendation([today, overdue], EnergyLevel.medium, now);
    expect(result!.taskId, 'overdue');
    expect(result.reason, contains('lewat deadline'));
  });

  test('due today beats tomorrow and reason is Deadline hari ini', () {
    final today = task('today', deadlineAt: now.add(const Duration(hours: 2)));
    final tomorrow =
        task('tomorrow', deadlineAt: now.add(const Duration(days: 1)));
    final result =
        computeRecommendation([tomorrow, today], EnergyLevel.medium, now);
    expect(result!.taskId, 'today');
    expect(result.reason, 'Deadline hari ini');
  });

  test('high priority beats low with identical deadline', () {
    final high = task('high',
        priority: 'high', deadlineAt: now.add(const Duration(days: 1)));
    final low = task('low',
        priority: 'low', deadlineAt: now.add(const Duration(days: 1)));
    final result =
        computeRecommendation([low, high], EnergyLevel.medium, now);
    expect(result!.taskId, 'high');
  });

  test('energy match boosts task', () {
    final match = task('match',
        deadlineAt: now.add(const Duration(days: 1)),
        energy: 'low',
        createdAt: createdNew);
    final noAffinity = task('none',
        deadlineAt: now.add(const Duration(days: 1)), createdAt: createdOld);
    final result =
        computeRecommendation([noAffinity, match], EnergyLevel.low, now);
    expect(result!.taskId, 'match');
    expect(result.reason, 'Energi cocok + prioritas tinggi');
  });

  test('energy mismatch does not force a task', () {
    final mismatch = task('mismatch',
        deadlineAt: now.add(const Duration(days: 1)),
        energy: 'high',
        createdAt: createdNew);
    final noAffinity = task('none',
        deadlineAt: now.add(const Duration(days: 1)), createdAt: createdOld);
    final result =
        computeRecommendation([mismatch, noAffinity], EnergyLevel.low, now);
    expect(result!.taskId, 'none');
  });

  test('in-progress bonus wins over identical pending task', () {
    final inProgress = task('ip',
        status: 'in_progress', deadlineAt: now.add(const Duration(days: 1)));
    final pending =
        task('pending', deadlineAt: now.add(const Duration(days: 1)));
    final result =
        computeRecommendation([pending, inProgress], EnergyLevel.medium, now);
    expect(result!.taskId, 'ip');
    expect(result.reason, 'Lanjutkan yang sudah dimulai');
  });

  test('tie-break: nearest deadline wins on equal score', () {
    final near = task('near', deadlineAt: now.add(const Duration(days: 5)));
    final far = task('far', deadlineAt: now.add(const Duration(days: 10)));
    final result = computeRecommendation([far, near], EnergyLevel.medium, now);
    expect(result!.taskId, 'near');
  });

  test('tie-break: older createdAt wins for identical unscheduled tasks', () {
    final older = task('older', createdAt: createdOld);
    final newer = task('newer', createdAt: createdNew);
    final result =
        computeRecommendation([newer, older], EnergyLevel.medium, now);
    expect(result!.taskId, 'older');
    expect(result.reason, 'Sudah lama menunggu');
  });

  test('scheduled beats unscheduled when all else equal', () {
    final scheduled =
        task('scheduled', deadlineAt: now.add(const Duration(days: 10)));
    final unscheduled = task('unscheduled');
    final result =
        computeRecommendation([unscheduled, scheduled], EnergyLevel.medium, now);
    expect(result!.taskId, 'scheduled');
  });

  test('low energy prefers short task', () {
    final short = task('short',
        deadlineAt: now.add(const Duration(days: 1)), duration: 10);
    final long = task('long',
        deadlineAt: now.add(const Duration(days: 1)), duration: 120);
    final result =
        computeRecommendation([long, short], EnergyLevel.low, now);
    expect(result!.taskId, 'short');
  });

  test('deterministic: identical input yields identical output', () {
    final candidates = [
      task('a', deadlineAt: now, priority: 'high'),
      task('b', deadlineAt: now.add(const Duration(days: 1))),
    ];
    final first = computeRecommendation(candidates, EnergyLevel.medium, now);
    final second = computeRecommendation(candidates, EnergyLevel.medium, now);
    expect(first!.taskId, second!.taskId);
    expect(first.reason, second.reason);
  });
}
