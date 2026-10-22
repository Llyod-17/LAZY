// ignore_for_file: recursive_getters — drift menganalisis getter via AST, tidak dieksekusi runtime

import 'package:drift/drift.dart';

/// Jadwal notifikasi lokal per task — satu baris per task (UNIQUE task_id).
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get taskId => text()();

  /// Android notification id (deterministik dari task id).
  IntColumn get notificationId => integer()();

  /// Waktu notifikasi (epoch ms, UTC).
  IntColumn get scheduledAt => integer()();

  TextColumn get status => text()
      .withDefault(const Constant('scheduled'))
      .check(status.isIn(['scheduled', 'cancelled', 'snoozed']))();

  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();

  @override
  List<String> get customConstraints => ['UNIQUE(task_id)'];
}
