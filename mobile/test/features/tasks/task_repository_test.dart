import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/repository/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });
  tearDown(() => db.close());

  group('createTask', () {
    test('insert + get returns row with defaults, title trimmed', () async {
      final task = await repo.createTask(title: '  Beli beras  ');
      expect(task.title, 'Beli beras');
      expect(task.status, 'pending');
      expect(task.priority, 'medium');
      expect(task.completedAt, isNull);

      final fetched = await repo.getTaskById(task.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, task.id);
    });

    test('rejects empty title', () {
      expect(() => repo.createTask(title: '   '), throwsArgumentError);
    });

    test('rejects title > 100 chars', () {
      expect(() => repo.createTask(title: 'x' * 101), throwsArgumentError);
    });

    test('rejects estimated duration out of range', () {
      expect(
        () => repo.createTask(title: 'a', estimatedDurationMin: 0),
        throwsArgumentError,
      );
      expect(
        () => repo.createTask(title: 'b', estimatedDurationMin: 481),
        throwsArgumentError,
      );
    });
  });

  group('duplicate validation', () {
    test('same title same day throws', () async {
      final deadline = DateTime.now().add(const Duration(days: 1));
      await repo.createTask(title: 'Rapat tim', deadlineAt: deadline);
      expect(
        () => repo.createTask(title: 'rapat TIM', deadlineAt: deadline),
        throwsA(isA<TaskDuplicateException>()),
      );
    });

    test('same title different day allowed', () async {
      final day1 = DateTime.now().add(const Duration(days: 1));
      final day2 = DateTime.now().add(const Duration(days: 2));
      await repo.createTask(title: 'Rapat', deadlineAt: day1);
      final second = await repo.createTask(title: 'Rapat', deadlineAt: day2);
      expect(second.title, 'Rapat');
    });

    test('same title without deadline allowed (unscheduled)', () async {
      await repo.createTask(title: 'Ide bebas');
      final second = await repo.createTask(title: 'Ide bebas');
      expect(second.title, 'Ide bebas');
    });
  });

  group('updateTask', () {
    test('partial update changes fields and bumps updatedAt', () async {
      final t = await repo.createTask(title: 'awal');
      final before = (await repo.getTaskById(t.id))!.updatedAt;
      await Future<void>.delayed(const Duration(milliseconds: 5));

      await repo.updateTask(t.id, title: 'baru', priority: 'high');
      final after = await repo.getTaskById(t.id);
      expect(after!.title, 'baru');
      expect(after.priority, 'high');
      expect(after.updatedAt, greaterThanOrEqualTo(before));
    });

    test('rejects invalid new title', () async {
      final t = await repo.createTask(title: 'ok');
      expect(() => repo.updateTask(t.id, title: ''), throwsArgumentError);
    });
  });

  group('delete', () {
    test('removes row', () async {
      final t = await repo.createTask(title: 'hapus');
      await repo.deleteTask(t.id);
      expect(await repo.getTaskById(t.id), isNull);
    });
  });

  group('complete/reopen', () {
    test('complete sets status and completedAt', () async {
      final t = await repo.createTask(title: 'selesai');
      await repo.completeTask(t.id);
      final done = await repo.getTaskById(t.id);
      expect(done!.status, 'completed');
      expect(done.completedAt, isNotNull);
    });

    test('reopen clears completedAt back to pending', () async {
      final t = await repo.createTask(title: 'ulang');
      await repo.completeTask(t.id);
      await repo.reopenTask(t.id);
      final reopened = await repo.getTaskById(t.id);
      expect(reopened!.status, 'pending');
      expect(reopened.completedAt, isNull);
    });
  });

  group('watchAllPendingTasks', () {
    test(
      'excludes completed, sorts deadline nulls last then createdAt',
      () async {
        final t1 = await repo.createTask(title: 'tanpa deadline');
        final t2 = await repo.createTask(
          title: 'deadline jauh',
          deadlineAt: DateTime.now().add(const Duration(days: 5)),
        );
        final t3 = await repo.createTask(
          title: 'deadline dekat',
          deadlineAt: DateTime.now().add(const Duration(hours: 2)),
        );
        final doneTask = await repo.createTask(
          title: 'sudah selesai',
          deadlineAt: DateTime.now(),
        );
        await repo.completeTask(doneTask.id);

        final list = await repo.watchAllPendingTasks().first;
        final ids = list.map((t) => t.id).toList();
        expect(ids, [t3.id, t2.id, t1.id]);
        expect(ids, isNot(contains(doneTask.id)));
      },
    );

    test('emits after create', () async {
      final before = await repo.watchAllPendingTasks().first;
      expect(before, isEmpty);
      await repo.createTask(title: 'baru');
      final after = await repo.watchAllPendingTasks().first;
      expect(after, hasLength(1));
    });
  });

  group('watchCompletedTasks', () {
    test('only completed tasks', () async {
      final a = await repo.createTask(title: 'dikerjakan');
      final b = await repo.createTask(title: 'selesai');
      await repo.completeTask(b.id);

      final completed = await repo.watchCompletedTasks().first;
      expect(completed.map((t) => t.id), [b.id]);
      expect(completed.map((t) => t.id), isNot(contains(a.id)));
    });
  });

  group('watchTodayTasks', () {
    test('only pending tasks with deadline today', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10);
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));

      final inToday = await repo.createTask(
        title: 'hari ini',
        deadlineAt: today,
      );
      final inTomorrow = await repo.createTask(
        title: 'besok',
        deadlineAt: tomorrow,
      );
      final inYesterday = await repo.createTask(
        title: 'kemarin',
        deadlineAt: yesterday,
      );
      final noDeadline = await repo.createTask(title: 'tanpa deadline');

      final list = await repo.watchTodayTasks().first;
      expect(list.map((t) => t.id), [inToday.id]);
      expect(list.map((t) => t.id), isNot(contains(inTomorrow.id)));
      expect(list.map((t) => t.id), isNot(contains(inYesterday.id)));
      expect(list.map((t) => t.id), isNot(contains(noDeadline.id)));
    });

    test('completed task today excluded', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 15);
      final t = await repo.createTask(
        title: 'nanti selesai',
        deadlineAt: today,
      );
      await repo.completeTask(t.id);
      final list = await repo.watchTodayTasks().first;
      expect(list, isEmpty);
    });
  });
}
