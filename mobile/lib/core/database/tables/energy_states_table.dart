// ignore_for_file: recursive_getters — drift menganalisis getter via AST, tidak dieksekusi runtime

import 'package:drift/drift.dart';

/// Singleton level energi — ARCHITECTURE.md §4.4 (id selalu 1).
class EnergyStates extends Table {
  IntColumn get id => integer()();

  TextColumn get level => text()
      .withDefault(const Constant('medium'))
      .check(level.isIn(['low', 'medium', 'high']))();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
