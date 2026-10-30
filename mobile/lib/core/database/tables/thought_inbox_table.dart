// ignore_for_file: recursive_getters — drift menganalisis getter via AST, tidak dieksekusi runtime

import 'package:drift/drift.dart';

import 'tasks_table.dart';

/// Ide tanpa jadwal — ARCHITECTURE.md §4.4.
@TableIndex(name: 'thought_inbox_created', columns: {#createdAt})
class ThoughtInbox extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get content => text().nullable()();

  IntColumn get createdAt => integer()();

  BoolColumn get converted => boolean().withDefault(const Constant(false))();

  TextColumn get convertedToTaskId =>
      text().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(title) BETWEEN 1 AND 100)',
  ];
}
