import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/producer/data/product_repository.dart';
import 'package:banabana_b2b/shared/models/product.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(apiClientProvider));
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductRepository _repo;
  ProductsNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getMyProducts());
  }

  Future<void> activate(String id) async {
    await _repo.activate(id);
    await load();
  }

  Future<void> deactivate(String id) async {
    await _repo.deactivate(id);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.deleteProduct(id);
    await load();
  }
}

final productsNotifierProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier(ref.watch(productRepositoryProvider));
});

final productDetailProvider = FutureProvider.family<Product, String>((ref, id) {
  return ref.watch(productRepositoryProvider).getProduct(id);
});
