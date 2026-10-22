import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../tasks/providers/task_providers.dart';
import 'reminder_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
  );
});
