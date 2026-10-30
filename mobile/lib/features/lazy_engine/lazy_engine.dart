/// Deterministic Lazy Engine — memilih 1 task paling layak dikerjakan.
/// Pure function, tanpa LLM/network, sesuai ARCHITECTURE.md §4.9.
library;

enum EnergyLevel { low, medium, high }

class CandidateTask {
  const CandidateTask({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.deadlineAt,
    this.estimatedDurationMin,
    this.energyAffinity,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? deadlineAt;
  final int? estimatedDurationMin;
  final String? energyAffinity;
}

class RecommendationResult {
  const RecommendationResult({
    required this.taskId,
    required this.taskTitle,
    required this.reason,
  });

  final String taskId;
  final String taskTitle;
  final String reason;
}

/// Bobot tetap — ubah di sini kalau perlu kalibrasi.
const _wUrgency = 0.40;
const _wPriority = 0.20;
const _wEnergy = 0.15;
const _wAge = 0.10;
const _wDuration = 0.10;
const _bonusInProgress = 0.05;

/// Mengembalikan rekomendasi terbaik atau `null` jika tidak ada kandidat.
RecommendationResult? computeRecommendation(
  List<CandidateTask> candidates,
  EnergyLevel energy,
  DateTime now,
) {
  final eligible = candidates
      .where((c) => c.status == 'pending' || c.status == 'in_progress')
      .toList();
  if (eligible.isEmpty) return null;

  CandidateTask? best;
  var bestScore = -1.0;

  for (final task in eligible) {
    final score = _score(task, energy, now);
    if (score > bestScore ||
        (score == bestScore && best != null && _tieBreak(task, best) < 0)) {
      bestScore = score;
      best = task;
    }
  }

  final result = best!;
  return RecommendationResult(
    taskId: result.id,
    taskTitle: result.title,
    reason: _reason(result, energy, now),
  );
}

double _score(CandidateTask t, EnergyLevel energy, DateTime now) {
  final score =
      _wUrgency * _urgencyScore(t.deadlineAt, now) +
      _wPriority * _priorityScore(t.priority) +
      _wEnergy * _energyScore(t.energyAffinity, energy) +
      _wAge * _ageScore(t.createdAt, now) +
      _wDuration * _durationScore(t.estimatedDurationMin, energy) +
      (t.status == 'in_progress' ? _bonusInProgress : 0);
  return score > 1.0 ? 1.0 : score;
}

double _urgencyScore(DateTime? deadline, DateTime now) {
  if (deadline == null) return 0.05;
  final deadlineDay = _startOfDay(deadline);
  final today = _startOfDay(now);
  final diffDays = deadlineDay.difference(today).inDays;
  if (diffDays < 0) return 1.0;
  if (diffDays == 0) return 0.8;
  if (diffDays == 1) return 0.6;
  if (diffDays <= 3) return 0.4;
  return 0.2;
}

double _priorityScore(String priority) => switch (priority) {
  'high' => 1.0,
  'medium' => 0.6,
  _ => 0.3,
};

double _energyScore(String? affinity, EnergyLevel current) {
  if (affinity == null) return 0.0;
  return affinity == current.name ? 1.0 : 0.0;
}

double _ageScore(DateTime createdAt, DateTime now) {
  final days = now.difference(createdAt).inDays;
  if (days <= 0) return 0.0;
  final score = days / 14.0;
  return score > 1.0 ? 1.0 : score;
}

double _durationScore(int? minutes, EnergyLevel energy) {
  if (minutes == null) return 0.5;
  return switch (energy) {
    EnergyLevel.low => minutes <= 15 ? 1.0 : (minutes <= 45 ? 0.6 : 0.2),
    EnergyLevel.medium => minutes <= 45 ? 1.0 : 0.6,
    EnergyLevel.high => minutes >= 30 ? 1.0 : 0.7,
  };
}

/// <0 berarti [a] menang tie-break.
int _tieBreak(CandidateTask a, CandidateTask b) {
  final ad = a.deadlineAt;
  final bd = b.deadlineAt;
  if (ad != null && bd != null) {
    final byDeadline = ad.compareTo(bd);
    if (byDeadline != 0) return byDeadline;
  } else if (ad != null) {
    return -1;
  } else if (bd != null) {
    return 1;
  }
  return a.createdAt.compareTo(b.createdAt);
}

String _reason(CandidateTask t, EnergyLevel energy, DateTime now) {
  if (t.deadlineAt != null) {
    final diffDays = _startOfDay(
      t.deadlineAt!,
    ).difference(_startOfDay(now)).inDays;
    if (diffDays < 0) return 'Sudah lewat deadline — kerjakan sekarang';
    if (diffDays == 0) return 'Deadline hari ini';
  }
  if (t.status == 'in_progress') return 'Lanjutkan yang sudah dimulai';
  if (t.energyAffinity == energy.name) return 'Energi cocok + prioritas tinggi';
  if (t.priority == 'high') return 'Prioritas tinggi';
  if (t.deadlineAt == null) return 'Sudah lama menunggu';
  return 'Deadline terdekat';
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
