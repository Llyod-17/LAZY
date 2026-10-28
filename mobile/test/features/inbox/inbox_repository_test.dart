import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/inbox/repository/inbox_repository.dart';

void main() {
  late AppDatabase db;
  late InboxRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InboxRepository(db);
  });

  tearDown(() => db.close());

  test('createThought persists and returns unconverted thought by default', () async {
    final thought = await repo.createThought(
      title: 'Bikin ide podcast',
      content: 'Tentang productivity buat orang mager',
    );

    expect(thought.title, 'Bikin ide podcast');
    expect(thought.content, 'Tentang productivity buat orang mager');
    expect(thought.converted, isFalse);
    expect(thought.convertedToTaskId, isNull);

    final list = await repo.watchAllUnconvertedThoughts().first;
    expect(list, hasLength(1));
    expect(list.first.id, thought.id);
  });

  test('createThought validates title length and trimming', () async {
    expect(() => repo.createThought(title: '   '), throwsArgumentError);
    expect(() => repo.createThought(title: 'a' * 101), throwsArgumentError);

    final valid = await repo.createThought(title: '  Belajar Golang  ');
    expect(valid.title, 'Belajar Golang');
  });

  test('watchAllUnconvertedThoughts filters out converted items and sorts desc', () async {
    final t1 = await repo.createThought(title: 'Ide 1');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final t2 = await repo.createThought(title: 'Ide 2');

    var list = await repo.watchAllUnconvertedThoughts().first;
    expect(list, hasLength(2));
    expect(list.first.id, t2.id); // newest first

    await repo.markAsConverted(t2.id, taskId: 'task-123');

    list = await repo.watchAllUnconvertedThoughts().first;
    expect(list, hasLength(1));
    expect(list.first.id, t1.id);
  });

  test('deleteThought removes item from database', () async {
    final thought = await repo.createThought(title: 'Ide sekali pakai');

    var list = await repo.watchAllUnconvertedThoughts().first;
    expect(list, hasLength(1));

    await repo.deleteThought(thought.id);

    list = await repo.watchAllUnconvertedThoughts().first;
    expect(list, isEmpty);
  });
}
