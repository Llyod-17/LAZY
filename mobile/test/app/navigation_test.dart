import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/app/app.dart';
import 'package:lazy_app/app/router.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

/// Pump app dengan DB in-memory. Wajib `await db.close()` di akhir body test
/// (drift pakai Timer internal saat stream cancel).
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  String initialLocation = '/',
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        routerProvider.overrideWith(
          (ref) => createRouter(initialLocation: initialLocation),
        ),
      ],
      child: const LazyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  testWidgets('starts on Today tab', (tester) async {
    final db = await pumpApp(tester);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Today Dashboard'), findsOneWidget);
    await db.close();
  });

  testWidgets('switch tab preserves shell (no duplicate nav)', (tester) async {
    final db = await pumpApp(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.text('Thought Inbox'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada tugas di sini'), findsOneWidget);
    await db.close();
  });

  testWidgets('deep link /tasks resolves', (tester) async {
    final db = await pumpApp(tester, initialLocation: '/tasks');
    expect(find.text('Belum ada tugas di sini'), findsOneWidget);
    await db.close();
  });

  testWidgets('deep link /inbox resolves', (tester) async {
    final db = await pumpApp(tester, initialLocation: '/inbox');
    expect(find.text('Thought Inbox'), findsOneWidget);
    await db.close();
  });

  testWidgets('FAB opens capture modal, close returns', (tester) async {
    final db = await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Quick Capture'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Today Dashboard'), findsOneWidget);
    await db.close();
  });

  testWidgets('modal route /task/:id resolves with param', (tester) async {
    final db = await pumpApp(tester, initialLocation: '/task/abc-123');
    expect(find.text('Tugas ini sudah tidak ada'), findsOneWidget);
    await db.close();
  });
}
