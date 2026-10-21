import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../repository/task_repository.dart';

/// Singleton database — ditutup saat container dispose.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(appDatabaseProvider));
});

/// Task pending (belum selesai), deadline terdekat dulu.
final allTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllPendingTasks();
});

/// Task pending yang deadline-nya hari ini (device timezone).
final todayTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTodayTasks();
});

/// Task yang sudah selesai.
final completedTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).watchCompletedTasks();
});

/// Satu task by id (null jika sudah dihapus).
final taskStreamProvider = StreamProvider.family<Task?, String>((ref, id) {
  return ref.watch(taskRepositoryProvider).watchTask(id);
});

/// Aksi mutasi task — state tidak disimpan di notifier, cukup delegasi ke repo.
/// Stream provider di atas memancarkan perubahan otomatis via Drift watch.
class TaskActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<Task> create({
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) {
    return _repo.createTask(
      title: title,
      description: description,
      priority: priority,
      deadlineAt: deadlineAt,
      estimatedDurationMin: estimatedDurationMin,
      energyAffinity: energyAffinity,
    );
  }

  Future<void> update(
    String id, {
    String? title,
    String? description,
    String? priority,
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) {
    return _repo.updateTask(
      id,
      title: title,
      description: description,
      priority: priority,
      deadlineAt: deadlineAt,
      estimatedDurationMin: estimatedDurationMin,
      energyAffinity: energyAffinity,
    );
  }

  Future<void> delete(String id) => _repo.deleteTask(id);

  Future<void> complete(String id) => _repo.completeTask(id);

  Future<void> reopen(String id) => _repo.reopenTask(id);
}

final taskActionsProvider =
    NotifierProvider<TaskActionsNotifier, void>(TaskActionsNotifier.new);
