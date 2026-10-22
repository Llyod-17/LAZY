import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';
import 'package:lazy_app/features/tasks/repository/task_repository.dart';
import 'package:lazy_app/features/today/screens/today_screen.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  Future<void> pumpToday(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders header, greeting, energy and lazy button', (tester) async {
    await pumpToday(tester);

    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text('Mau mulai dari mana?'), findsOneWidget);
    expect(find.text('Energi sekarang'), findsOneWidget);
    expect(find.text('Rendah'), findsOneWidget);
    expect(find.text('Kasih aku yang paling ringan'), findsOneWidget);
    expect(find.text('Kegiatan hari ini'), findsOneWidget);
    expect(find.text('Hari ini kosong'), findsOneWidget);
    await db.close();
  });

  testWidgets('lists today tasks', (tester) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    await repo.createTask(
      title: 'Meeting pagi',
      deadlineAt: dayStart.add(const Duration(hours: 9)),
    );
    await repo.createTask(
      title: 'Besok lusa',
      deadlineAt: dayStart.add(const Duration(days: 2)),
    );

    await pumpToday(tester);

    expect(find.text('Meeting pagi'), findsOneWidget);
    expect(find.text('Besok lusa'), findsNothing);
    await db.close();
  });

  testWidgets('lazy button reveals recommendation card', (tester) async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    await repo.createTask(
      title: 'Cuci piring',
      priority: 'high',
      deadlineAt: dayStart.add(const Duration(hours: 1)),
    );

    await pumpToday(tester);
    expect(find.text('Saran untukmu'), findsNothing);

    await tester.tap(find.text('Kasih aku yang paling ringan'));
    await tester.pumpAndSettle();

    expect(find.text('Saran untukmu'), findsOneWidget);
    expect(find.text('Kerjakan'), findsOneWidget);
    expect(find.text('Saran Lain'), findsOneWidget);
    expect(find.text('Cuci piring'), findsWidgets);
    await db.close();
  });

  testWidgets('lazy button without tasks shows friendly snackbar', (tester) async {
    await pumpToday(tester);

    await tester.tap(find.text('Kasih aku yang paling ringan'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada kegiatan hari ini. Santai dulu ya'), findsOneWidget);
    expect(find.text('Saran untukmu'), findsNothing);
    await db.close();
  });
}
