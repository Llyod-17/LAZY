import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('in-memory init creates tasks table + indexes', () async {
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type IN ('table', 'index')")
        .get()
        .then((rows) => rows.map((r) => r.read<String>('name')).toSet());
    expect(tables, containsAll(['tasks', 'tasks_deadline', 'tasks_status', 'tasks_created']));
  });

  test('insert + read roundtrip with defaults', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: 't-1',
          title: 'Belajar Drift',
          createdAt: now,
          updatedAt: now,
        ));

    final task = await (db.select(db.tasks)..where((t) => t.id.equals('t-1'))).getSingle();
    expect(task.title, 'Belajar Drift');
    expect(task.status, 'pending');
    expect(task.priority, 'medium');
    expect(task.deadlineAt, isNull);
    expect(task.energyAffinity, isNull);
    expect(task.completedAt, isNull);
  });

  test('CHECK rejects invalid status', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    expect(
      () => db.into(db.tasks).insert(TasksCompanion.insert(
            id: 't-2',
            title: 'x',
            status: const Value('bogus'),
            createdAt: now,
            updatedAt: now,
          )),
      throwsA(anything),
    );
  });

  test('CHECK rejects invalid energy_affinity but accepts null', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: 't-3',
          title: 'tanpa energi',
          createdAt: now,
          updatedAt: now,
        ));
    expect(
      () => db.into(db.tasks).insert(TasksCompanion.insert(
            id: 't-4',
            title: 'energi invalid',
            energyAffinity: const Value('extreme'),
            createdAt: now,
            updatedAt: now,
          )),
      throwsA(anything),
    );
  });

  test('title length 1-100 enforced', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    expect(
      () => db.into(db.tasks).insert(TasksCompanion.insert(
            id: 't-5',
            title: '',
            createdAt: now,
            updatedAt: now,
          )),
      throwsA(anything),
    );
  });

  test('hard delete removes row', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.tasks).insert(TasksCompanion.insert(
          id: 't-6',
          title: 'hapus saya',
          createdAt: now,
          updatedAt: now,
        ));
    await (db.delete(db.tasks)..where((t) => t.id.equals('t-6'))).go();
    final rows = await db.select(db.tasks).get();
    expect(rows, isEmpty);
  });
}
