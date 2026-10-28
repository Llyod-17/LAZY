import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/inbox/repository/inbox_repository.dart';
import 'package:lazy_app/features/inbox/screens/inbox_screen.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  late AppDatabase db;
  late InboxRepository inboxRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    inboxRepo = InboxRepository(db);
  });

  Future<void> pumpInbox(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: InboxScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders empty state when inbox is empty', (tester) async {
    await pumpInbox(tester);

    expect(find.text('Inbox kamu bersih'), findsOneWidget);
    expect(
        find.text('Ada ide lewat di kepala? Catat langsung di sini.'),
        findsOneWidget);
    await db.close();
  });

  testWidgets('renders list of unconverted thoughts', (tester) async {
    await inboxRepo.createThought(
      title: 'Beli kopi arabika',
      content: 'Cari yang roasting-an medium',
    );
    await pumpInbox(tester);

    expect(find.text('Beli kopi arabika'), findsOneWidget);
    expect(find.text('Cari yang roasting-an medium'), findsOneWidget);
    expect(find.text('Jadikan Kegiatan'), findsOneWidget);
    await db.close();
  });

  testWidgets('delete button removes item from inbox', (tester) async {
    final thought = await inboxRepo.createThought(title: 'Ide buang');
    await pumpInbox(tester);

    expect(find.text('Ide buang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Ide buang'), findsNothing);
    final row = await (db.select(db.thoughtInbox)
          ..where((t) => t.id.equals(thought.id)))
        .getSingleOrNull();
    expect(row, isNull);
    await db.close();
  });

  testWidgets('can convert thought to scheduled task', (tester) async {
    final thought = await inboxRepo.createThought(
      title: 'Bikin prototype LAZY',
      content: 'Pakai Flutter dan Riverpod',
    );
    await pumpInbox(tester);

    await tester.tap(find.text('Jadikan Kegiatan'));
    await tester.pumpAndSettle();

    expect(find.text('Simpan sebagai Kegiatan'), findsOneWidget);

    await tester.tap(find.text('Simpan sebagai Kegiatan'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox kamu bersih'), findsOneWidget);

    final task = await (db.select(db.tasks)
          ..where((t) => t.title.equals('Bikin prototype LAZY')))
        .getSingleOrNull();
    expect(task, isNotNull);
    expect(task!.description, 'Pakai Flutter dan Riverpod');
    expect(task.deadlineAt, isNotNull);

    final updatedThought = await (db.select(db.thoughtInbox)
          ..where((t) => t.id.equals(thought.id)))
        .getSingleOrNull();
    expect(updatedThought!.converted, isTrue);
    expect(updatedThought.convertedToTaskId, task.id);

    await db.close();
  });
}
