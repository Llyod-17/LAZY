import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/core/network/ai_api_client.dart';
import 'package:lazy_app/features/braindump/screens/brain_dump_preview_screen.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));

  Future<void> pumpPreview(
    WidgetTester tester,
    List<ExtractedTask> tasks,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: BrainDumpPreviewScreen(initialTasks: tasks),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all preview items and does not persist before confirmation',
      (tester) async {
    final tasks = [
      const ExtractedTask(
        title: 'Meeting klien',
        suggestedDate: '2025-10-25',
        suggestedTime: '10:00',
        priority: 'high',
        reason: 'Penting',
      ),
      const ExtractedTask(
        title: 'Beli buku bacaan',
        suggestedDate: null, // Unscheduled
        priority: null,
      ),
    ];

    await pumpPreview(tester, tasks);

    expect(find.text('Meeting klien'), findsOneWidget);
    expect(find.text('2025-10-25'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Beli buku bacaan'), findsOneWidget);
    expect(find.text('Unscheduled (ke Inbox)'), findsOneWidget);

    // Verify DB still empty
    final dbTasks = await db.select(db.tasks).get();
    final dbThoughts = await db.select(db.thoughtInbox).get();
    expect(dbTasks, isEmpty);
    expect(dbThoughts, isEmpty);

    await db.close();
  });

  testWidgets('deleting item removes it from preview list', (tester) async {
    final tasks = [
      const ExtractedTask(title: 'Tugas yang salah'),
    ];

    await pumpPreview(tester, tasks);
    expect(find.text('Tugas yang salah'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Tugas yang salah'), findsNothing);
    expect(find.text('Semua tugas telah dihapus.'), findsOneWidget);

    await db.close();
  });

  testWidgets('confirm save writes scheduled to tasks and unscheduled to inbox',
      (tester) async {
    final tasks = [
      const ExtractedTask(
        title: 'Kerjakan laporan',
        suggestedDate: '2025-10-22',
        suggestedTime: '15:30',
        priority: 'high',
      ),
      const ExtractedTask(
        title: 'Ide startup AI',
        suggestedDate: null,
      ),
    ];

    await pumpPreview(tester, tasks);

    await tester.tap(find.byKey(const Key('confirm-save-btn')));
    await tester.pumpAndSettle();

    // Verify scheduled task saved to tasks table
    final dbTasks = await db.select(db.tasks).get();
    expect(dbTasks, hasLength(1));
    expect(dbTasks.first.title, 'Kerjakan laporan');
    expect(dbTasks.first.priority, 'high');
    expect(dbTasks.first.deadlineAt, isNotNull);

    // Verify unscheduled task saved to thought_inbox table
    final dbThoughts = await db.select(db.thoughtInbox).get();
    expect(dbThoughts, hasLength(1));
    expect(dbThoughts.first.title, 'Ide startup AI');
    expect(dbThoughts.first.converted, isFalse);

    await db.close();
  });
}
