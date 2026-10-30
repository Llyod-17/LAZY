import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

/// Dilempar saat create/update task bentrok duplikat (judul sama + hari deadline sama).
class TaskDuplicateException implements Exception {
  TaskDuplicateException(this.message);
  final String message;

  @override
  String toString() => 'TaskDuplicateException: $message';
}

/// Repository CRUD task — skema Drift, duplikat dijaga di lapisan ini (PRD F02).
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  Future<Task> createTask({
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) async {
    final trimmed = _validateTitle(title);
    _validateDuration(estimatedDurationMin);

    if (deadlineAt != null &&
        await isDuplicate(title: trimmed, deadlineAt: deadlineAt)) {
      throw TaskDuplicateException(
        'Task "$trimmed" sudah ada pada hari yang sama',
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return _db
        .into(_db.tasks)
        .insertReturning(
          TasksCompanion.insert(
            id: const Uuid().v4(),
            title: trimmed,
            description: description == null
                ? const Value.absent()
                : Value(description),
            priority: Value(priority),
            deadlineAt: deadlineAt == null
                ? const Value.absent()
                : Value(deadlineAt.toUtc().millisecondsSinceEpoch),
            estimatedDurationMin: estimatedDurationMin == null
                ? const Value.absent()
                : Value(estimatedDurationMin),
            energyAffinity: energyAffinity == null
                ? const Value.absent()
                : Value(energyAffinity),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Duplikat = judul (case-insensitive, trimmed) sama + deadline di hari lokal yang sama.
  Future<bool> isDuplicate({
    required String title,
    required DateTime deadlineAt,
  }) async {
    final local = deadlineAt.toLocal();
    final dayStart = DateTime(local.year, local.month, local.day);
    final startMs = dayStart.toUtc().millisecondsSinceEpoch;
    final endMs = dayStart
        .add(const Duration(days: 1))
        .toUtc()
        .millisecondsSinceEpoch;

    final q = _db.select(_db.tasks)
      ..where(
        (t) =>
            t.title.lower().equals(title.trim().toLowerCase()) &
            t.deadlineAt.isBiggerOrEqualValue(startMs) &
            t.deadlineAt.isSmallerThanValue(endMs),
      );
    return (await q.get()).isNotEmpty;
  }

  Future<Task?> getTaskById(String id) {
    return (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Stream satu task — reaktif terhadap edit/complete.
  Stream<Task?> watchTask(String id) {
    return (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> updateTask(
    String id, {
    String? title,
    String? description,
    String? priority,
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) async {
    if (title != null) _validateTitle(title);
    if (estimatedDurationMin != null) _validateDuration(estimatedDurationMin);

    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        title: title == null ? const Value.absent() : Value(title.trim()),
        description: description == null
            ? const Value.absent()
            : Value(description),
        priority: priority == null ? const Value.absent() : Value(priority),
        deadlineAt: deadlineAt == null
            ? const Value.absent()
            : Value(deadlineAt.toUtc().millisecondsSinceEpoch),
        estimatedDurationMin: estimatedDurationMin == null
            ? const Value.absent()
            : Value(estimatedDurationMin),
        energyAffinity: energyAffinity == null
            ? const Value.absent()
            : Value(energyAffinity),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteTask(String id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Task belum selesai (pending + in_progress), urut deadline terdekat (null di akhir).
  Stream<List<Task>> watchAllPendingTasks() {
    final q = _db.select(_db.tasks)
      ..where((t) => t.status.isNotIn(['completed']))
      ..orderBy([
        (t) => OrderingTerm(
          expression: t.deadlineAt,
          mode: OrderingMode.asc,
          nulls: NullsOrder.last,
        ),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);
    return q.watch();
  }

  /// Task pending yang deadline-nya hari ini (device timezone).
  Stream<List<Task>> watchTodayTasks() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final startMs = dayStart.toUtc().millisecondsSinceEpoch;
    final endMs = dayStart
        .add(const Duration(days: 1))
        .toUtc()
        .millisecondsSinceEpoch;

    final q = _db.select(_db.tasks)
      ..where(
        (t) =>
            t.status.isNotIn(['completed']) &
            t.deadlineAt.isBiggerOrEqualValue(startMs) &
            t.deadlineAt.isSmallerThanValue(endMs),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.deadlineAt, mode: OrderingMode.asc),
      ]);
    return q.watch();
  }

  /// Task yang sudah selesai, yang terbaru diselesaikan dulu.
  Stream<List<Task>> watchCompletedTasks() {
    final q = _db.select(_db.tasks)
      ..where((t) => t.status.equals('completed'))
      ..orderBy([
        (t) => OrderingTerm(
          expression: t.completedAt,
          mode: OrderingMode.desc,
          nulls: NullsOrder.last,
        ),
      ]);
    return q.watch();
  }

  Future<void> startTask(String id) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('in_progress'),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> completeTask(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('completed'),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> reopenTask(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('pending'),
        completedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  String _validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw ArgumentError.value(title, 'title', 'Title harus 1-100 karakter');
    }
    return trimmed;
  }

  void _validateDuration(int? minutes) {
    if (minutes != null && (minutes < 1 || minutes > 480)) {
      throw ArgumentError.value(
        minutes,
        'estimatedDurationMin',
        'Durasi harus 1-480 menit',
      );
    }
  }
}
