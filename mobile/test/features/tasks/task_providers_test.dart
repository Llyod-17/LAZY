import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
  });
  tearDown(() => db.close());

  test('taskRepositoryProvider builds from database', () {
    final repo = container.read(taskRepositoryProvider);
    expect(repo, isNotNull);
  });

  test('allTasksStreamProvider emits created tasks', () async {
    final actions = container.read(taskActionsProvider.notifier);
    await actions.create(title: 'Satu');
    await actions.create(title: 'Dua');

    final tasks = await container.read(allTasksStreamProvider.future);
    expect(tasks.map((t) => t.title), containsAll(['Satu', 'Dua']));
  });

  test('allTasksStreamProvider re-emits after complete', () async {
    final actions = container.read(taskActionsProvider.notifier);
    final t = await actions.create(title: 'Selesai nanti');

    await actions.complete(t.id);
    final tasks = await container.read(allTasksStreamProvider.future);
    expect(tasks.map((t) => t.id), isNot(contains(t.id)));
  });

  test('allTasksStreamProvider re-emits after delete', () async {
    final actions = container.read(taskActionsProvider.notifier);
    final t = await actions.create(title: 'Hapus');

    await actions.delete(t.id);
    final tasks = await container.read(allTasksStreamProvider.future);
    expect(tasks, isEmpty);
  });

  test('todayTasksStreamProvider only today deadline', () async {
    final actions = container.read(taskActionsProvider.notifier);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 14);
    final tomorrow = today.add(const Duration(days: 1));

    await actions.create(title: 'Hari ini', deadlineAt: today);
    await actions.create(title: 'Besok', deadlineAt: tomorrow);

    final tasks = await container.read(todayTasksStreamProvider.future);
    expect(tasks.map((t) => t.title), ['Hari ini']);
  });

  test('watch stream emits live on mutation', () async {
    final actions = container.read(taskActionsProvider.notifier);
    final sub = container.listen(
      allTasksStreamProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await actions.create(title: 'Live');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final latest = container.read(allTasksStreamProvider).value;
    expect(latest?.map((t) => t.title), contains('Live'));
  });
}
