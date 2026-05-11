import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';
import 'package:banabana_b2b/shared/widgets/app_bottom_nav.dart';

class WholesalerShell extends ConsumerWidget {
  const WholesalerShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int get _currentIndex {
    if (location.startsWith('/shop/home')) return 0;
    if (location.startsWith('/shop/catalog') ||
        location.startsWith('/shop/product')) { return 1; }
    if (location.startsWith('/shop/cart')) return 2;
    if (location.startsWith('/shop/orders')) return 3;
    if (location.startsWith('/shop/profile') ||
        location.startsWith('/shop/dashboard')) { return 4; }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/shop/home');
      case 1: context.go('/shop/catalog');
      case 2: context.go('/shop/cart');
      case 3: context.go('/shop/orders');
      case 4: context.go('/shop/profile');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    final items = [
      const AppNavItem(icon: Symbols.home, activeIcon: Symbols.home, label: 'Accueil'),
      const AppNavItem(icon: Symbols.store, activeIcon: Symbols.store, label: 'Catalogue'),
      AppNavItem(
        icon: Symbols.shopping_cart,
        activeIcon: Symbols.shopping_cart,
        label: 'Panier',
        badgeCount: cartCount,
      ),
      const AppNavItem(icon: Symbols.receipt_long, activeIcon: Symbols.receipt_long, label: 'Commandes'),
      const AppNavItem(icon: Symbols.person, activeIcon: Symbols.person, label: 'Profil'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(
        items: items,
        currentIndex: _currentIndex,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}
