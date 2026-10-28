import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

/// Repository untuk Thought Inbox (ide/catatan tanpa jadwal).
class InboxRepository {
  InboxRepository(this._db);

  final AppDatabase _db;

  Future<ThoughtInboxData> createThought({
    required String title,
    String? content,
  }) {
    final trimmed = _validateTitle(title);
    final now = DateTime.now().millisecondsSinceEpoch;

    return _db.into(_db.thoughtInbox).insertReturning(
          ThoughtInboxCompanion.insert(
            id: const Uuid().v4(),
            title: trimmed,
            content: content == null || content.trim().isEmpty
                ? const Value.absent()
                : Value(content.trim()),
            createdAt: now,
          ),
        );
  }

  Stream<List<ThoughtInboxData>> watchAllUnconvertedThoughts() {
    final q = _db.select(_db.thoughtInbox)
      ..where((t) => t.converted.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return q.watch();
  }

  Future<void> deleteThought(String id) {
    return (_db.delete(_db.thoughtInbox)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markAsConverted(String id, {String? taskId}) async {
    await (_db.update(_db.thoughtInbox)..where((t) => t.id.equals(id))).write(
      ThoughtInboxCompanion(
        converted: const Value(true),
        convertedToTaskId:
            taskId == null ? const Value.absent() : Value(taskId),
      ),
    );
  }

  String _validateTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      throw ArgumentError.value(title, 'title', 'Title harus 1-100 karakter');
    }
    return trimmed;
  }
}
