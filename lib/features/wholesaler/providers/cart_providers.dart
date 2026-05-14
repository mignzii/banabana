import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String variantId;
  final String productId;
  final String productTitle;
  final String variantLabel;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.variantId,
    required this.productId,
    required this.productTitle,
    required this.variantLabel,
    required this.unitPrice,
    required this.quantity,
  });
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void add({
    required String variantId,
    required String productId,
    required String productTitle,
    required String variantLabel,
    required double unitPrice,
    int quantity = 1,
  }) {
    final idx = state.indexWhere((i) => i.variantId == variantId);
    if (idx >= 0) {
      final updated = List<CartItem>.from(state);
      updated[idx].quantity += quantity;
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          variantId: variantId,
          productId: productId,
          productTitle: productTitle,
          variantLabel: variantLabel,
          unitPrice: unitPrice,
          quantity: quantity,
        ),
      ];
    }
  }

  void updateQuantity(String variantId, int quantity) {
    if (quantity <= 0) {
      remove(variantId);
      return;
    }
    state = state
        .map((i) => i.variantId == variantId
            ? CartItem(
                variantId: i.variantId,
                productId: i.productId,
                productTitle: i.productTitle,
                variantLabel: i.variantLabel,
                unitPrice: i.unitPrice,
                quantity: quantity,
              )
            : i)
        .toList();
  }

  void remove(String variantId) {
    state = state.where((i) => i.variantId != variantId).toList();
  }

  void clear() => state = [];

  double get total =>
      state.fold(0, (sum, i) => sum + i.unitPrice * i.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).total;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
});
