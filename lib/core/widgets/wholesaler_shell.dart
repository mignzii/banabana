import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';
import 'package:banabana_b2b/features/wholesaler/providers/cart_providers.dart';

class WholesalerShell extends ConsumerWidget {
  const WholesalerShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int get _currentIndex {
    if (location.startsWith('/shop/home')) {
      return 0;
    }
    if (location.startsWith('/shop/catalog') ||
        location.startsWith('/shop/product')) {
      return 1;
    }
    if (location.startsWith('/shop/cart')) {
      return 2;
    }
    if (location.startsWith('/shop/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray400,
        currentIndex: _currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/shop/home');
            case 1:
              context.go('/shop/catalog');
            case 2:
              context.go('/shop/cart');
            case 3:
              context.go('/shop/profile');
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Symbols.home),
            activeIcon: Icon(Symbols.home, fill: 1),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Symbols.store),
            activeIcon: Icon(Symbols.store, fill: 1),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Symbols.shopping_cart),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Symbols.shopping_cart, fill: 1),
            ),
            label: 'Panier',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Symbols.person),
            activeIcon: Icon(Symbols.person, fill: 1),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
