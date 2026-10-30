import 'package:drift/drift.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';

/// Notification id deterministik: satu task selalu pakai id yang sama,
/// jadi cancel/reschedule tak perlu tabel pemetaan.
/// ponytail: hash 31-bit — tabrakan praktis nol, ganti counter kalau perlu.
int notificationIdFor(String taskId) => taskId.hashCode & 0x7fffffff;

/// Penjadwalan reminder lokal yang mengikuti lifecycle task.
class ReminderService {
  ReminderService(
    this._db,
    this._notifications, {
    Future<String> Function()? timezoneResolver,
  }) : _timezoneResolver =
           timezoneResolver ??
           (() async => (await FlutterTimezone.getLocalTimezone()).identifier);

  final AppDatabase _db;
  final NotificationService _notifications;
  final Future<String> Function() _timezoneResolver;

  static const snoozeDuration = Duration(minutes: 10);

  bool _ready = false;

  /// Init plugin + database zona waktu device (fallback UTC bila gagal).
  Future<void> init() async {
    if (_ready) return;
    await _notifications.init();
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await _timezoneResolver()));
    } catch (_) {
      // Zona tak dikenal → tetap jalan dengan UTC.
    }
    _ready = true;
  }

  /// Jadwalkan (atau jadwalkan ulang) reminder deadline task.
  /// Task tanpa deadline / sudah completed / deadline lewat → dibatalkan saja.
  Future<void> scheduleForTask(Task task) async {
    await cancelForTask(task.id);
    final deadlineMs = task.deadlineAt;
    if (deadlineMs == null || task.status == 'completed') return;

    final deadline = DateTime.fromMillisecondsSinceEpoch(
      deadlineMs,
      isUtc: true,
    ).toLocal();
    if (!deadline.isAfter(DateTime.now())) return;

    await init();
    final notificationId = notificationIdFor(task.id);
    await _notifications.schedule(
      id: notificationId,
      when: deadline,
      title: task.title,
      body: 'Deadline ${DateFormat('HH:mm').format(deadline)}',
      payload: task.id,
    );
    await _replaceRow(
      taskId: task.id,
      notificationId: notificationId,
      scheduledAt: deadline,
      status: 'scheduled',
      snoozeCount: 0,
    );
  }

  /// Batalkan notifikasi & tandai row cancelled (row dipertahankan untuk audit).
  Future<void> cancelForTask(String taskId) async {
    await _notifications.cancel(notificationIdFor(taskId));
    await (_db.update(_db.reminders)..where((r) => r.taskId.equals(taskId)))
        .write(const RemindersCompanion(status: Value('cancelled')));
  }

  /// Tunda +10 menit; reschedule notifikasi dan naikkan snooze_count.
  Future<Reminder?> snoozeForTask(String taskId) async {
    final task = await (_db.select(
      _db.tasks,
    )..where((t) => t.id.equals(taskId))).getSingleOrNull();
    if (task == null) return null;

    final row = await (_db.select(
      _db.reminders,
    )..where((r) => r.taskId.equals(taskId))).getSingleOrNull();
    final snoozeCount = (row?.snoozeCount ?? 0) + 1;
    final when = DateTime.now().add(snoozeDuration);

    await _notifications.cancel(notificationIdFor(taskId));
    await init();
    await _notifications.schedule(
      id: notificationIdFor(taskId),
      when: when,
      title: task.title,
      body: 'Ditunda $snoozeCount× · deadline tadi',
      payload: task.id,
    );
    await _replaceRow(
      taskId: taskId,
      notificationId: notificationIdFor(taskId),
      scheduledAt: when,
      status: 'snoozed',
      snoozeCount: snoozeCount,
    );
    return (_db.select(
      _db.reminders,
    )..where((r) => r.taskId.equals(taskId))).getSingle();
  }

  Future<Reminder?> getForTask(String taskId) {
    return (_db.select(
      _db.reminders,
    )..where((r) => r.taskId.equals(taskId))).getSingleOrNull();
  }

  Future<void> _replaceRow({
    required String taskId,
    required int notificationId,
    required DateTime scheduledAt,
    required String status,
    required int snoozeCount,
  }) async {
    await (_db.delete(
      _db.reminders,
    )..where((r) => r.taskId.equals(taskId))).go();
    await _db
        .into(_db.reminders)
        .insert(
          RemindersCompanion.insert(
            taskId: taskId,
            notificationId: notificationId,
            scheduledAt: scheduledAt.toUtc().millisecondsSinceEpoch,
            status: Value(status),
            snoozeCount: Value(snoozeCount),
          ),
        );
  }
}
