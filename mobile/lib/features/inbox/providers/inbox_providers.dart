import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../tasks/providers/task_providers.dart';
import '../repository/inbox_repository.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return InboxRepository(ref.watch(appDatabaseProvider));
});

final unconvertedThoughtsStreamProvider =
    StreamProvider<List<ThoughtInboxData>>((ref) {
      return ref.watch(inboxRepositoryProvider).watchAllUnconvertedThoughts();
    });

class InboxActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  InboxRepository get _repo => ref.read(inboxRepositoryProvider);
  TaskActionsNotifier get _taskActions =>
      ref.read(taskActionsProvider.notifier);

  Future<ThoughtInboxData> create({required String title, String? content}) {
    return _repo.createThought(title: title, content: content);
  }

  Future<void> delete(String id) => _repo.deleteThought(id);

  /// Konversi thought jadi task baru, lalu tandai thought sbg converted.
  Future<Task> convertToTask({
    required String thoughtId,
    required String title,
    String? description,
    String priority = 'medium',
    DateTime? deadlineAt,
    int? estimatedDurationMin,
  }) async {
    final task = await _taskActions.create(
      title: title,
      description: description,
      priority: priority,
      deadlineAt: deadlineAt,
      estimatedDurationMin: estimatedDurationMin,
    );
    await _repo.markAsConverted(thoughtId, taskId: task.id);
    return task;
  }
}

final inboxActionsProvider = NotifierProvider<InboxActionsNotifier, void>(
  InboxActionsNotifier.new,
);
