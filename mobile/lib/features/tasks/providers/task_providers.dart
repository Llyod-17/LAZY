import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../reminders/reminder_providers.dart';
import '../../reminders/reminder_service.dart';
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

  ReminderService get _reminders => ref.read(reminderServiceProvider);

  /// Notifikasi bersifat best-effort: kegagalan plugin tidak boleh
  /// menggagalkan operasi task (offline-first tetap jalan).
  Future<void> _syncReminder(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // sengaja diabaikan
    }
  }

  Future<Task> create({
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) async {
    final task = await _repo.createTask(
      title: title,
      description: description,
      priority: priority,
      deadlineAt: deadlineAt,
      estimatedDurationMin: estimatedDurationMin,
      energyAffinity: energyAffinity,
    );
    await _syncReminder(() => _reminders.scheduleForTask(task));
    return task;
  }

  Future<void> update(
    String id, {
    String? title,
    String? description,
    String? priority,
    DateTime? deadlineAt,
    int? estimatedDurationMin,
    String? energyAffinity,
  }) async {
    await _repo.updateTask(
      id,
      title: title,
      description: description,
      priority: priority,
      deadlineAt: deadlineAt,
      estimatedDurationMin: estimatedDurationMin,
      energyAffinity: energyAffinity,
    );
    final task = await _repo.getTaskById(id);
    if (task != null) {
      await _syncReminder(() => _reminders.scheduleForTask(task));
    }
  }

  Future<void> delete(String id) async {
    await _repo.deleteTask(id);
    await _syncReminder(() => _reminders.cancelForTask(id));
  }

  Future<void> start(String id) => _repo.startTask(id);

  Future<void> complete(String id) async {
    await _repo.completeTask(id);
    await _syncReminder(() => _reminders.cancelForTask(id));
  }

  Future<void> reopen(String id) async {
    await _repo.reopenTask(id);
    final task = await _repo.getTaskById(id);
    if (task != null) {
      await _syncReminder(() => _reminders.scheduleForTask(task));
    }
  }
}

final taskActionsProvider = NotifierProvider<TaskActionsNotifier, void>(
  TaskActionsNotifier.new,
);
