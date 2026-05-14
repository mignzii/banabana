import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  const CartItem({
    required this.variantId,
    required this.productId,
    required this.productTitle,
    required this.variantLabel,
    required this.unitPrice,
    required this.quantity,
  });

  final String variantId;
  final String productId;
  final String productTitle;
  final String variantLabel;
  final double unitPrice;
  final int quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        variantId: variantId,
        productId: productId,
        productTitle: productTitle,
        variantLabel: variantLabel,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );
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
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + quantity)
          else
            state[i],
      ];
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
        .map((i) => i.variantId == variantId ? i.copyWith(quantity: quantity) : i)
        .toList();
  }

  void remove(String variantId) {
    state = state.where((i) => i.variantId != variantId).toList();
  }

  void clear() => state = [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (sum, i) => sum + i.unitPrice * i.quantity);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, i) => sum + i.quantity);
});
