import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/producer/data/order_repository.dart';
import 'package:banabana_b2b/shared/models/order.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final OrderRepository _repo;
  OrdersNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getMyOrders());
  }

  Future<void> accept(String id) async {
    await _repo.accept(id);
    await load();
  }

  Future<void> reject(String id, String reason) async {
    await _repo.reject(id, reason);
    await load();
  }

  Future<void> ship(String id, Map<String, dynamic> data) async {
    await _repo.ship(id, data);
    await load();
  }
}

final ordersNotifierProvider =
    StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(ref.watch(orderRepositoryProvider));
});

final orderDetailProvider = FutureProvider.family<Order, String>((ref, id) {
  return ref.watch(orderRepositoryProvider).getOrder(id);
});
