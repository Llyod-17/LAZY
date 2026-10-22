import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/energy/widgets/energy_selector.dart';
import 'package:lazy_app/features/lazy_engine/lazy_engine.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));

  Future<void> pumpSelector(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: Scaffold(body: Padding(padding: EdgeInsets.all(16), child: EnergySelector())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders three options with medium selected by default',
      (tester) async {
    await pumpSelector(tester);

    expect(find.text('Rendah'), findsOneWidget);
    expect(find.text('Sedang'), findsOneWidget);
    expect(find.text('Tinggi'), findsOneWidget);

    final medium = tester.widget<ChoiceChip>(find.byKey(const Key('energy-medium')));
    expect(medium.selected, isTrue);
    await db.close();
  });

  testWidgets('tap Tinggi persists and updates selection', (tester) async {
    await pumpSelector(tester);

    await tester.tap(find.byKey(const Key('energy-high')));
    await tester.pumpAndSettle();

    final row = await db.select(db.energyStates).getSingle();
    expect(row.level, EnergyLevel.high.name);
    final high = tester.widget<ChoiceChip>(find.byKey(const Key('energy-high')));
    expect(high.selected, isTrue);
    await db.close();
  });

  testWidgets('reflects pre-existing stored energy', (tester) async {
    await db.into(db.energyStates).insert(EnergyStatesCompanion.insert(
          id: const Value(1),
          level: const Value('low'),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ));
    await pumpSelector(tester);

    final low = tester.widget<ChoiceChip>(find.byKey(const Key('energy-low')));
    expect(low.selected, isTrue);
    await db.close();
  });
}
