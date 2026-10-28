import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/core/widgets/app_button.dart';
import 'package:lazy_app/features/capture/screens/quick_capture_screen.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));

  Future<void> pumpCapture(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: QuickCaptureScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders input field and disabled save buttons', (tester) async {
    await pumpCapture(tester);

    expect(find.byKey(const Key('quick-capture-input')), findsOneWidget);
    expect(find.text('Tulis tugas atau ide kamu di sini...'), findsOneWidget);

    final taskBtn = tester.widget<AppButton>(find.byKey(const Key('save-as-task-btn')));
    expect(taskBtn.onTap, isNull);

    final inboxBtn = tester.widget<AppButton>(find.byKey(const Key('save-as-inbox-btn')));
    expect(inboxBtn.onTap, isNull);
    await db.close();
  });

  testWidgets('typing enables save buttons', (tester) async {
    await pumpCapture(tester);

    await tester.enterText(find.byKey(const Key('quick-capture-input')), 'Beli susu');
    await tester.pumpAndSettle();

    final taskBtn = tester.widget<AppButton>(find.byKey(const Key('save-as-task-btn')));
    expect(taskBtn.onTap, isNotNull);

    final inboxBtn = tester.widget<AppButton>(find.byKey(const Key('save-as-inbox-btn')));
    expect(inboxBtn.onTap, isNotNull);
    await db.close();
  });

  testWidgets('save as task persists to database with deadline', (tester) async {
    await pumpCapture(tester);

    await tester.enterText(
      find.byKey(const Key('quick-capture-input')),
      'Kerjakan PR',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-as-task-btn')));
    await tester.pumpAndSettle();

    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Kerjakan PR');
    expect(tasks.first.deadlineAt, isNotNull);
    await db.close();
  });

  testWidgets('save as inbox persists thought', (tester) async {
    await pumpCapture(tester);

    await tester.enterText(
      find.byKey(const Key('quick-capture-input')),
      'Ide aplikasi baru',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('save-as-inbox-btn')));
    await tester.pumpAndSettle();

    final thoughts = await db.select(db.thoughtInbox).get();
    expect(thoughts, hasLength(1));
    expect(thoughts.first.title, 'Ide aplikasi baru');
    expect(thoughts.first.converted, isFalse);
    await db.close();
  });
}
