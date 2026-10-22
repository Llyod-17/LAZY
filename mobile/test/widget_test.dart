import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/app/app.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  testWidgets('LazyApp renders Today dashboard', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const LazyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mau mulai dari mana?'), findsOneWidget);
    await db.close();
  });
}
