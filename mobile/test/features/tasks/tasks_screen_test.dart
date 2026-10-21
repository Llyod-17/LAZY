import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';
import 'package:lazy_app/features/tasks/screens/tasks_screen.dart';

Future<void> pumpTasks(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: TasksScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));

  Future<Task> insertTask(String title, {String status = 'pending', int? deadlineAt}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.into(db.tasks).insertReturning(TasksCompanion.insert(
          id: title,
          title: title,
          status: Value(status),
          deadlineAt: deadlineAt == null ? const Value.absent() : Value(deadlineAt),
          createdAt: now,
          updatedAt: now,
          completedAt: status == 'completed' ? Value(now) : const Value.absent(),
        ));
  }

  testWidgets('shows empty state when no tasks', (tester) async {
    await pumpTasks(tester, db);
    expect(find.text('Belum ada tugas di sini'), findsOneWidget);
    await db.close();
  });

  testWidgets('shows pending tasks from database', (tester) async {
    await insertTask('Beli susu');
    await insertTask('Kirim laporan');
    await pumpTasks(tester, db);

    expect(find.text('Beli susu'), findsOneWidget);
    expect(find.text('Kirim laporan'), findsOneWidget);
    expect(find.text('Belum ada tugas di sini'), findsNothing);
    await db.close();
  });

  testWidgets('completed tasks hidden on Semua, shown on Selesai', (tester) async {
    await insertTask('Aktif');
    await insertTask('Sudah done', status: 'completed');
    await pumpTasks(tester, db);

    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Sudah done'), findsNothing);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Sudah done'), findsOneWidget);
    expect(find.text('Aktif'), findsNothing);
    await db.close();
  });

  testWidgets('Tertunda filter shows only status pending', (tester) async {
    await insertTask('Pending biasa');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: 'ip',
          title: 'Sedang dikerjakan',
          status: const Value('in_progress'),
          createdAt: now,
          updatedAt: now,
        ));
    await pumpTasks(tester, db);

    await tester.tap(find.text('Tertunda'));
    await tester.pumpAndSettle();

    expect(find.text('Pending biasa'), findsOneWidget);
    expect(find.text('Sedang dikerjakan'), findsNothing);
    await db.close();
  });

  testWidgets('checkbox tap completes task instantly', (tester) async {
    await insertTask('Centang saya');
    await pumpTasks(tester, db);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    final task = await (db.select(db.tasks)..where((t) => t.id.equals('Centang saya')))
        .getSingle();
    expect(task.status, 'completed');
    expect(task.completedAt, isNotNull);
    expect(find.text('Centang saya'), findsNothing);
    await db.close();
  });

  testWidgets('checkbox tap on completed reopens', (tester) async {
    await insertTask('Buka lagi', status: 'completed');
    await pumpTasks(tester, db);
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    final task = await (db.select(db.tasks)..where((t) => t.id.equals('Buka lagi')))
        .getSingle();
    expect(task.status, 'pending');
    expect(task.completedAt, isNull);
    await db.close();
  });
}
