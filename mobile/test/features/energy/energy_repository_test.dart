import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/features/energy/repository/energy_repository.dart';
import 'package:lazy_app/features/lazy_engine/lazy_engine.dart';

void main() {
  late AppDatabase db;
  late EnergyRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = EnergyRepository(db);
  });
  tearDown(() => db.close());

  test('defaults to medium when never checked in', () async {
    expect(await repo.getEnergy(), EnergyLevel.medium);
  });

  test('set then get returns stored level', () async {
    await repo.setEnergy(EnergyLevel.high);
    expect(await repo.getEnergy(), EnergyLevel.high);
  });

  test('set overwrites singleton row (no duplicates)', () async {
    await repo.setEnergy(EnergyLevel.low);
    await repo.setEnergy(EnergyLevel.high);
    final rows = await db.select(db.energyStates).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 1);
    expect(await repo.getEnergy(), EnergyLevel.high);
  });

  test('watchEnergy emits stored value', () async {
    await repo.setEnergy(EnergyLevel.low);
    expect(await repo.watchEnergy().first, EnergyLevel.low);
  });

  test('watchEnergy re-emits after change', () async {
    await repo.setEnergy(EnergyLevel.low);
    final values = <EnergyLevel>[];
    final sub = repo.watchEnergy().listen(values.add);
    addTearDown(sub.cancel);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await repo.setEnergy(EnergyLevel.high);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(values.last, EnergyLevel.high);
  });

  test('persists across repository instances on same database', () async {
    await repo.setEnergy(EnergyLevel.high);
    final other = EnergyRepository(db);
    expect(await other.getEnergy(), EnergyLevel.high);
  });
}
