import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:banabana_b2b/core/theme/app_colors.dart';

class ProducerShell extends StatelessWidget {
  const ProducerShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int get _currentIndex {
    if (location.startsWith('/producer/home')) return 0;
    if (location.startsWith('/producer/orders')) return 2;
    if (location.startsWith('/producer/profile')) return 3;
    // dashboard, products, inventory, analytics, messages → tab 1
    return 1;
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/producer/home');
            case 1:
              context.go('/producer/dashboard');
            case 2:
              context.go('/producer/orders');
            case 3:
              context.go('/producer/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Symbols.home),
            activeIcon: Icon(Symbols.home, fill: 1),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.dashboard),
            activeIcon: Icon(Symbols.dashboard, fill: 1),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.receipt_long),
            activeIcon: Icon(Symbols.receipt_long, fill: 1),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.person),
            activeIcon: Icon(Symbols.person, fill: 1),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
