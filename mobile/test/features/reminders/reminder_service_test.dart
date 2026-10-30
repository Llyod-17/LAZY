import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/core/notifications/notification_service.dart';
import 'package:lazy_app/features/reminders/reminder_service.dart';
import 'package:lazy_app/features/tasks/repository/task_repository.dart';

class MockNotifications extends Mock implements NotificationService {}

void main() {
  late AppDatabase db;
  late TaskRepository tasks;
  late MockNotifications notifications;
  late ReminderService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    tasks = TaskRepository(db);
    notifications = MockNotifications();
    when(() => notifications.init()).thenAnswer((_) async {});
    when(
      () => notifications.schedule(
        id: any(named: 'id'),
        when: any(named: 'when'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => notifications.cancel(any())).thenAnswer((_) async {});
    service = ReminderService(
      db,
      notifications,
      timezoneResolver: () async => 'Asia/Jakarta',
    );
  });

  tearDown(() => db.close());

  test('schedules future deadline task and stores row', () async {
    final deadline = DateTime.now().add(const Duration(hours: 2));
    final task = await tasks.createTask(title: 'Meeting', deadlineAt: deadline);

    await service.scheduleForTask(task);

    verify(
      () => notifications.schedule(
        id: notificationIdFor(task.id),
        when: any(named: 'when'),
        title: 'Meeting',
        body: any(named: 'body'),
        payload: task.id,
      ),
    ).called(1);

    final row = await service.getForTask(task.id);
    expect(row, isNotNull);
    expect(row!.status, 'scheduled');
    expect(row.notificationId, notificationIdFor(task.id));
    expect(row.scheduledAt, deadline.toUtc().millisecondsSinceEpoch);
    expect(row.snoozeCount, 0);
  });

  test('does not schedule task without deadline', () async {
    final task = await tasks.createTask(title: 'Tanpa deadline');

    await service.scheduleForTask(task);

    verifyNever(
      () => notifications.schedule(
        id: any(named: 'id'),
        when: any(named: 'when'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    );
    expect(await service.getForTask(task.id), isNull);
  });

  test('does not schedule completed task', () async {
    final task = await tasks.createTask(
      title: 'Sudah beres',
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await tasks.completeTask(task.id);
    final completed = (await tasks.getTaskById(task.id))!;

    await service.scheduleForTask(completed);

    verifyNever(
      () => notifications.schedule(
        id: any(named: 'id'),
        when: any(named: 'when'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    );
  });

  test('does not schedule deadline in the past', () async {
    final task = await tasks.createTask(
      title: 'Telah lewat',
      deadlineAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

    await service.scheduleForTask(task);

    verifyNever(
      () => notifications.schedule(
        id: any(named: 'id'),
        when: any(named: 'when'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        payload: any(named: 'payload'),
      ),
    );
  });

  test('reschedule keeps a single row per task', () async {
    final task = await tasks.createTask(
      title: 'Meeting',
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await service.scheduleForTask(task);

    final moved = DateTime.now().add(const Duration(hours: 3));
    await tasks.updateTask(task.id, deadlineAt: moved);
    await service.scheduleForTask((await tasks.getTaskById(task.id))!);

    final rows = await db.select(db.reminders).get();
    expect(rows, hasLength(1));
    expect(rows.single.scheduledAt, moved.toUtc().millisecondsSinceEpoch);
  });

  test('cancel marks row cancelled and cancels notification', () async {
    final task = await tasks.createTask(
      title: 'Meeting',
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await service.scheduleForTask(task);
    clearInteractions(notifications);

    await service.cancelForTask(task.id);

    verify(() => notifications.cancel(notificationIdFor(task.id))).called(1);
    expect((await service.getForTask(task.id))!.status, 'cancelled');
  });

  test('snooze reschedules +10 minutes and increments count', () async {
    final task = await tasks.createTask(
      title: 'Meeting',
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await service.scheduleForTask(task);

    final before = DateTime.now();
    final snoozed = await service.snoozeForTask(task.id);

    expect(snoozed!.status, 'snoozed');
    expect(snoozed.snoozeCount, 1);
    final scheduled = DateTime.fromMillisecondsSinceEpoch(
      snoozed.scheduledAt,
      isUtc: true,
    );
    expect(scheduled.isAfter(before.add(const Duration(minutes: 9))), isTrue);
    expect(scheduled.isBefore(before.add(const Duration(minutes: 11))), isTrue);

    final again = await service.snoozeForTask(task.id);
    expect(again!.snoozeCount, 2);
  });

  test('snooze unknown task returns null', () async {
    expect(await service.snoozeForTask('missing'), isNull);
  });

  test('task lifecycle: complete cancels scheduled reminder', () async {
    final task = await tasks.createTask(
      title: 'Meeting',
      deadlineAt: DateTime.now().add(const Duration(hours: 1)),
    );
    await service.scheduleForTask(task);
    clearInteractions(notifications);

    await tasks.completeTask(task.id);
    await service.cancelForTask(task.id);

    expect((await service.getForTask(task.id))!.status, 'cancelled');
    verify(() => notifications.cancel(notificationIdFor(task.id))).called(1);
  });
}
