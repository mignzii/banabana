import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/producer/data/inventory_repository.dart';
import 'package:banabana_b2b/shared/models/inventory.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(apiClientProvider));
});

class InventoryNotifier extends StateNotifier<AsyncValue<List<Inventory>>> {
  final InventoryRepository _repo;
  InventoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  Future<void> recordMovement({
    required String variantId,
    required MovementType type,
    required int quantity,
    String? reason,
    String? notes,
  }) async {
    await _repo.recordMovement(
      variantId: variantId,
      type: type,
      quantity: quantity,
      reason: reason,
      notes: notes,
    );
    await load();
  }
}

final inventoryNotifierProvider =
    StateNotifierProvider<InventoryNotifier, AsyncValue<List<Inventory>>>((ref) {
  return InventoryNotifier(ref.watch(inventoryRepositoryProvider));
});

final inventoryAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getAlerts();
});

final stockMovementsProvider = FutureProvider<List<StockMovement>>((ref) {
  return ref.watch(inventoryRepositoryProvider).getMovements();
});
