import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Channel pengingat kegiatan — ARCHITECTURE.md §5.
const lazyReminderChannel = AndroidNotificationChannel(
  'lazy_reminders',
  'Pengingat Kegiatan',
  description: 'Pengingat kegiatan yang punya deadline',
  importance: Importance.high,
);

/// Wrapper tipis plugin notifikasi lokal; plugin bisa di-inject untuk test.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    await _android?.createNotificationChannel(lazyReminderChannel);
    _initialized = true;
  }

  /// Jadwalkan notifikasi satu kali pada [when] (waktu lokal device).
  Future<void> schedule({
    required int id,
    required DateTime when,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          lazyReminderChannel.id,
          lazyReminderChannel.name,
          channelDescription: lazyReminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: title,
      body: body,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// Android 13+: dialog izin POST_NOTIFICATIONS. Platform lain dianggap izin.
  Future<bool> requestPermissions() async {
    return await _android?.requestNotificationsPermission() ?? true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android {
    return _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
  }
}
