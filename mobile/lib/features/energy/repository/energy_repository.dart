import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../lazy_engine/lazy_engine.dart';

/// Akses level energi saat ini (singleton row id=1).
class EnergyRepository {
  EnergyRepository(this._db);

  final AppDatabase _db;

  static const _singletonId = 1;

  /// Level tersimpan; default `medium` jika belum pernah check-in.
  Future<EnergyLevel> getEnergy() async {
    final row = await (_db.select(
      _db.energyStates,
    )..where((t) => t.id.equals(_singletonId))).getSingleOrNull();
    return _parse(row?.level);
  }

  Stream<EnergyLevel> watchEnergy() {
    return (_db.select(_db.energyStates)
          ..where((t) => t.id.equals(_singletonId)))
        .watchSingleOrNull()
        .map((row) => _parse(row?.level));
  }

  Future<void> setEnergy(EnergyLevel level) {
    return _db
        .into(_db.energyStates)
        .insertOnConflictUpdate(
          EnergyStatesCompanion.insert(
            id: Value(_singletonId),
            level: Value(level.name),
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  EnergyLevel _parse(String? value) {
    for (final level in EnergyLevel.values) {
      if (level.name == value) return level;
    }
    return EnergyLevel.medium;
  }
}
