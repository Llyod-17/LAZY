import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lazy_engine/lazy_engine.dart';
import '../../tasks/providers/task_providers.dart';
import '../repository/energy_repository.dart';

final energyRepositoryProvider = Provider<EnergyRepository>((ref) {
  return EnergyRepository(ref.watch(appDatabaseProvider));
});

/// Level energi aktif — reaktif terhadap perubahan check-in.
final currentEnergyProvider = StreamProvider<EnergyLevel>((ref) {
  return ref.watch(energyRepositoryProvider).watchEnergy();
});
