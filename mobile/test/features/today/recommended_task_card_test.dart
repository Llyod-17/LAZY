import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/lazy_engine/lazy_engine.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';
import 'package:lazy_app/features/tasks/repository/task_repository.dart';
import 'package:lazy_app/features/today/providers/recommendation_provider.dart';
import 'package:lazy_app/features/today/widgets/lazy_button.dart';
import 'package:lazy_app/features/today/widgets/recommended_task_card.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  Future<void> pumpCard(
    WidgetTester tester,
    RecommendationResult result, {
    VoidCallback? onSuggestAnother,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: RecommendedTaskCard(
                recommendation: result,
                onSuggestAnother: onSuggestAnother ?? () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows title and reason', (tester) async {
    await pumpCard(
      tester,
      const RecommendationResult(
        taskId: 'x',
        taskTitle: 'Balas email klien',
        reason: 'Deadline hari ini',
      ),
    );

    expect(find.text('Balas email klien'), findsOneWidget);
    expect(find.text('Deadline hari ini'), findsOneWidget);
    expect(find.text('Saran untukmu'), findsOneWidget);
    await db.close();
  });

  testWidgets('Kerjakan sets task status to in_progress', (tester) async {
    final task = await repo.createTask(
      title: 'Tugas ringan',
      deadlineAt: DateTime.now().add(const Duration(hours: 2)),
    );
    await pumpCard(
      tester,
      RecommendationResult(
        taskId: task.id,
        taskTitle: task.title,
        reason: 'Deadline hari ini',
      ),
    );

    await tester.tap(find.text('Kerjakan'));
    await tester.pumpAndSettle();

    final updated = await repo.getTaskById(task.id);
    expect(updated!.status, 'in_progress');
    await db.close();
  });

  testWidgets('Saran Lain fires callback', (tester) async {
    var taps = 0;
    await pumpCard(
      tester,
      const RecommendationResult(
        taskId: 'x',
        taskTitle: 'Task A',
        reason: 'Deadline besok',
      ),
      onSuggestAnother: () => taps++,
    );

    await tester.tap(find.text('Saran Lain'));
    expect(taps, 1);
    await db.close();
  });

  testWidgets('LazyButton triggers callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LazyButton(onPressed: () => taps++),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.bolt));
    expect(taps, 1);
  });

  test('ranking skips completed and cycles through candidates', () async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final soon = await repo.createTask(
      title: 'Deadline dekat',
      priority: 'high',
      deadlineAt: dayStart.add(const Duration(hours: 1)),
    );
    await repo.createTask(
      title: 'Nanti sore',
      deadlineAt: dayStart.add(const Duration(hours: 2)),
    );
    final done = await repo.createTask(
      title: 'Sudah selesai',
      deadlineAt: dayStart.add(const Duration(hours: 1)),
    );
    await repo.completeTask(done.id);

    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    container.listen(recommendationProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final first = container.read(recommendationProvider);
    expect(first.ranked, hasLength(2));
    expect(first.current!.taskId, soon.id);
    expect(first.current!.taskTitle, 'Deadline dekat');

    container.read(recommendationProvider.notifier).suggestAnother();
    final second = container.read(recommendationProvider);
    expect(second.current!.taskId, isNot(soon.id));
    expect(second.current!.taskTitle, 'Nanti sore');

    await db.close();
  });
}
