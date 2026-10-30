import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/app/app.dart';
import 'package:lazy_app/app/router.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

/// Wajib `await db.close()` di akhir body test (drift Timer internal).
Future<AppDatabase> pumpAt(WidgetTester tester, String location) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        routerProvider.overrideWith(
          (ref) => createRouter(initialLocation: location),
        ),
      ],
      child: const LazyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  const tabs = ['Today', 'Inbox', 'Tasks', 'Settings'];

  Future<void> tapTab(WidgetTester tester, String tab) async {
    await tester.tap(
      find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)),
    );
    await tester.pumpAndSettle();
  }

  for (final tab in tabs) {
    testWidgets('tab $tab renders without crash', (tester) async {
      final db = await pumpAt(tester, '/');
      await tapTab(tester, tab);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      await db.close();
    });
  }

  const modalRoutes = ['/capture', '/braindump', '/task/smoke-1'];
  for (final route in modalRoutes) {
    testWidgets('modal $route renders without crash', (tester) async {
      final db = await pumpAt(tester, route);
      expect(find.byType(Scaffold), findsWidgets);
      expect(tester.takeException(), isNull);
      await db.close();
    });
  }

  testWidgets('full tab walk: all 4 tabs in one session', (tester) async {
    final db = await pumpAt(tester, '/');
    for (final tab in tabs) {
      await tapTab(tester, tab);
      expect(tester.takeException(), isNull);
    }
    await db.close();
  });
}
