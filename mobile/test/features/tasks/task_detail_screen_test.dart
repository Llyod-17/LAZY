import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';
import 'package:lazy_app/features/tasks/repository/task_repository.dart';
import 'package:lazy_app/features/tasks/screens/task_detail_screen.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  Future<void> pumpDetail(WidgetTester tester, String taskId) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: TaskDetailScreen(taskId: taskId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('prefills fields from task', (tester) async {
    final task = await repo.createTask(
      title: 'Judul awal',
      description: 'Deskripsi awal',
      priority: 'high',
      estimatedDurationMin: 30,
    );
    await pumpDetail(tester, task.id);

    expect(find.text('Judul awal'), findsOneWidget);
    expect(find.text('Deskripsi awal'), findsOneWidget);
    expect(find.text('Tinggi'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    await db.close();
  });

  testWidgets('edit + save persists to database', (tester) async {
    final task = await repo.createTask(title: 'Lama');
    await pumpDetail(tester, task.id);

    await tester.enterText(find.byKey(const Key('task-title-field')), 'Judul baru');
    await tester.enterText(find.byKey(const Key('task-duration-field')), '45');
    await tester.tap(find.byKey(const Key('task-save')));
    await tester.pumpAndSettle();

    final updated = await repo.getTaskById(task.id);
    expect(updated!.title, 'Judul baru');
    expect(updated.estimatedDurationMin, 45);
    expect(find.text('Perubahan tersimpan'), findsOneWidget);
    await db.close();
  });

  testWidgets('empty title blocks save', (tester) async {
    final task = await repo.createTask(title: 'Asli');
    await pumpDetail(tester, task.id);

    await tester.enterText(find.byKey(const Key('task-title-field')), '   ');
    await tester.tap(find.byKey(const Key('task-save')));
    await tester.pumpAndSettle();

    expect(find.text('Judul wajib diisi'), findsOneWidget);
    expect((await repo.getTaskById(task.id))!.title, 'Asli');
    await db.close();
  });

  testWidgets('invalid duration blocks save', (tester) async {
    final task = await repo.createTask(title: 'Asli');
    await pumpDetail(tester, task.id);

    await tester.enterText(find.byKey(const Key('task-duration-field')), '999');
    await tester.tap(find.byKey(const Key('task-save')));
    await tester.pumpAndSettle();

    expect(find.text('Isi 1–480 menit'), findsOneWidget);
    expect((await repo.getTaskById(task.id))!.estimatedDurationMin, isNull);
    await db.close();
  });

  testWidgets('delete asks confirmation then removes task', (tester) async {
    final task = await repo.createTask(title: 'Akan dihapus');
    await pumpDetail(tester, task.id);

    await tester.tap(find.byKey(const Key('task-delete')));
    await tester.pumpAndSettle();
    expect(find.text('Hapus tugas ini?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();

    expect(await repo.getTaskById(task.id), isNull);
    expect(find.text('Tugas ini sudah tidak ada'), findsOneWidget);
    await db.close();
  });

  testWidgets('cancel delete keeps task', (tester) async {
    final task = await repo.createTask(title: 'Tetap ada');
    await pumpDetail(tester, task.id);

    await tester.tap(find.byKey(const Key('task-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(await repo.getTaskById(task.id), isNotNull);
    expect(find.text('Tetap ada'), findsOneWidget);
    await db.close();
  });
}
