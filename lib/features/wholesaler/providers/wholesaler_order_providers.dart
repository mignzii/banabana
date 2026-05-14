import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/wholesaler/data/wholesaler_order_repository.dart';
import 'package:banabana_b2b/shared/models/order.dart';

final wholesalerOrderRepositoryProvider =
    Provider<WholesalerOrderRepository>((ref) {
  return WholesalerOrderRepository(ref.watch(apiClientProvider));
});

class WholesalerOrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final WholesalerOrderRepository _repo;
  WholesalerOrdersNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getMyOrders());
  }

  Future<Order> placeOrder(List<Map<String, dynamic>> items) async {
    final order = await _repo.createOrder(items);
    await load();
    return order;
  }

  Future<void> cancel(String id) async {
    await _repo.cancel(id);
    await load();
  }
}

final wholesalerOrdersProvider = StateNotifierProvider<
    WholesalerOrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return WholesalerOrdersNotifier(
      ref.watch(wholesalerOrderRepositoryProvider));
});

final wholesalerOrderDetailProvider =
    FutureProvider.family<Order, String>((ref, id) {
  return ref.watch(wholesalerOrderRepositoryProvider).getOrder(id);
});
