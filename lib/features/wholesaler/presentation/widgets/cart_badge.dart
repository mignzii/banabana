import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';

class CartBadge extends ConsumerWidget {
  final Widget child;

  const CartBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartItemCountProvider);
    if (count == 0) return child;
    return Badge(
      label: Text('$count'),
      backgroundColor: AppColors.secondary,
      textColor: Colors.black,
      child: child,
    );
  }
}
