import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/shared/widgets/app_bottom_nav.dart';

class ProducerShell extends StatelessWidget {
  const ProducerShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const _items = [
    AppNavItem(
      icon: Symbols.home,
      activeIcon: Symbols.home,
      label: 'Accueil',
    ),
    AppNavItem(
      icon: Symbols.inventory_2,
      activeIcon: Symbols.inventory_2,
      label: 'Produits',
    ),
    AppNavItem(
      icon: Symbols.receipt_long,
      activeIcon: Symbols.receipt_long,
      label: 'Commandes',
    ),
    AppNavItem(
      icon: Symbols.chat_bubble,
      activeIcon: Symbols.chat_bubble,
      label: 'Messages',
    ),
    AppNavItem(
      icon: Symbols.person,
      activeIcon: Symbols.person,
      label: 'Profil',
    ),
  ];

  int get _currentIndex {
    if (location.startsWith('/producer/home')) return 0;
    if (location.startsWith('/producer/products') ||
        location.startsWith('/producer/inventory') ||
        location.startsWith('/producer/analytics') ||
        location.startsWith('/producer/dashboard')) { return 1; }
    if (location.startsWith('/producer/orders')) return 2;
    if (location.startsWith('/producer/messages')) return 3;
    if (location.startsWith('/producer/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/producer/home');
      case 1: context.go('/producer/products');
      case 2: context.go('/producer/orders');
      case 3: context.go('/producer/messages');
      case 4: context.go('/producer/profile');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: AppBottomNav(
      items: _items,
      currentIndex: _currentIndex,
      onTap: (i) => _onTap(context, i),
    ),
  );
}
