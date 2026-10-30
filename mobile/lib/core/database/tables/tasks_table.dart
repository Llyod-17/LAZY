// ignore_for_file: recursive_getters — drift menganalisis getter via AST, tidak dieksekusi runtime

import 'package:drift/drift.dart';

/// Tabel tasks — skema sesuai ARCHITECTURE.md §4.4.
@TableIndex(name: 'tasks_deadline', columns: {#deadlineAt})
@TableIndex(name: 'tasks_status', columns: {#status})
@TableIndex(name: 'tasks_created', columns: {#createdAt})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()
      .withDefault(const Constant('pending'))
      .check(status.isIn(['pending', 'in_progress', 'completed']))();

  TextColumn get priority => text()
      .withDefault(const Constant('medium'))
      .check(priority.isIn(['low', 'medium', 'high']))();

  IntColumn get deadlineAt => integer().nullable()();
  IntColumn get estimatedDurationMin => integer().nullable()();

  TextColumn get energyAffinity => text().nullable().check(
    energyAffinity.isNull() | energyAffinity.isIn(['low', 'medium', 'high']),
  )();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
