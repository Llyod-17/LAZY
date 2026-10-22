import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Notifikasi tidak boleh menahan startup; kegagalan plugin cukup diabaikan.
  unawaited(NotificationService().init().catchError((_) {}));
  runApp(const ProviderScope(child: LazyApp()));
}
