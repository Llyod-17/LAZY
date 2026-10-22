import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lazy_app/core/notifications/notification_service.dart';

class MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class MockAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

void main() {
  late MockPlugin plugin;
  late MockAndroidPlugin android;
  late NotificationService service;

  setUpAll(() {
    registerFallbackValue(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    registerFallbackValue(const AndroidNotificationChannel('x', 'y'));
  });

  setUp(() {
    plugin = MockPlugin();
    android = MockAndroidPlugin();
    when(() => plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()).thenReturn(android);
    when(() => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: null,
          onDidReceiveBackgroundNotificationResponse: null,
        )).thenAnswer((_) async => true);
    when(() => android.createNotificationChannel(any()))
        .thenAnswer((_) async {});
    service = NotificationService(plugin: plugin);
  });

  test('init initializes plugin with android settings', () async {
    await service.init();

    verify(() => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: null,
          onDidReceiveBackgroundNotificationResponse: null,
        )).called(1);
  });

  test('init creates lazy reminder channel', () async {
    await service.init();

    final channel = verify(() => android.createNotificationChannel(captureAny()))
        .captured
        .single as AndroidNotificationChannel;
    expect(channel.id, 'lazy_reminders');
    expect(channel.name, 'Pengingat Kegiatan');
    expect(channel.importance, Importance.high);
  });

  test('init is idempotent', () async {
    await service.init();
    await service.init();

    verify(() => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: null,
          onDidReceiveBackgroundNotificationResponse: null,
        )).called(1);
  });

  test('requestPermissions forwards to android plugin', () async {
    when(() => android.requestNotificationsPermission())
        .thenAnswer((_) async => true);

    expect(await service.requestPermissions(), isTrue);
    verify(() => android.requestNotificationsPermission()).called(1);
  });

  test('requestPermissions returns false when denied', () async {
    when(() => android.requestNotificationsPermission())
        .thenAnswer((_) async => false);

    expect(await service.requestPermissions(), isFalse);
  });
}
