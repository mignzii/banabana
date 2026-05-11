import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/auth/screens/login_screen.dart';
import 'package:banabana_b2b/features/auth/screens/otp_screen.dart';
import 'package:banabana_b2b/features/auth/screens/register_screen.dart';
import 'package:banabana_b2b/features/auth/screens/set_pin_screen.dart';
import 'package:banabana_b2b/features/auth/screens/pin_login_screen.dart';
import 'package:banabana_b2b/features/auth/screens/kyc_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/analytics_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/inventory_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/messages_stub_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/order_detail_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/orders_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/producer_dashboard_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/producer_home_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/product_detail_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/product_form_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/products_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/shop_dashboard_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/shop_home_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/catalog_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/product_public_detail_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/cart_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/wholesaler_orders_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/wholesaler_order_detail_screen.dart';
import 'package:banabana_b2b/core/widgets/producer_shell.dart';
import 'package:banabana_b2b/core/widgets/wholesaler_shell.dart';
import 'package:banabana_b2b/shared/screens/profile_screen.dart';

final _producerShellKey = GlobalKey<NavigatorState>(debugLabel: 'producerShell');
final _wholesalerShellKey =
    GlobalKey<NavigatorState>(debugLabel: 'wholesalerShell');

String _roleHome(String? role) {
  return switch (role) {
    'producer' => '/producer/home',
    'wholesaler' => '/shop/home',
    'vendor' => '/vendor/dashboard',
    _ => '/auth/login',
  };
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return _roleHome(authState.user?.role);
      return null;
    },
    routes: [
      // Auth routes (no shell)
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>;
          return OtpScreen(phone: extra['phone']!, role: extra['role']!);
        },
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return RegisterScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/auth/set-pin',
        builder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return SetPinScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/auth/pin',
        builder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return PinLoginScreen(phone: phone);
        },
      ),
      GoRoute(path: '/auth/kyc', builder: (_, __) => const KycScreen()),

      // Producer shell
      ShellRoute(
        navigatorKey: _producerShellKey,
        builder: (context, state, child) => ProducerShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/producer/home',
            name: 'producer-home',
            builder: (_, __) => const ProducerHomeScreen(),
          ),
          GoRoute(
            path: '/producer/dashboard',
            name: 'producer-dashboard',
            builder: (_, __) => const ProducerDashboardScreen(),
          ),
          GoRoute(
            path: '/producer/products',
            name: 'producer-products',
            builder: (_, __) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/producer/products/new',
            name: 'producer-product-new',
            builder: (_, __) => const ProductFormScreen(),
          ),
          GoRoute(
            path: '/producer/products/:id',
            name: 'producer-product-detail',
            builder: (_, state) =>
                ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/producer/products/:id/edit',
            name: 'producer-product-edit',
            builder: (_, state) =>
                ProductFormScreen(productId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/producer/orders',
            name: 'producer-orders',
            builder: (_, __) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/producer/orders/:id',
            name: 'producer-order-detail',
            builder: (_, state) =>
                OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/producer/inventory',
            name: 'producer-inventory',
            builder: (_, __) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/producer/analytics',
            name: 'producer-analytics',
            builder: (_, __) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/producer/messages',
            name: 'producer-messages',
            builder: (_, __) => const MessagesStubScreen(),
          ),
          GoRoute(
            path: '/producer/profile',
            name: 'producer-profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Wholesaler shell
      ShellRoute(
        navigatorKey: _wholesalerShellKey,
        builder: (context, state, child) => WholesalerShell(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/shop/home',
            name: 'shop-home',
            builder: (_, __) => const ShopHomeScreen(),
          ),
          GoRoute(
            path: '/shop/dashboard',
            name: 'shop-dashboard',
            builder: (_, __) => const ShopDashboardScreen(),
          ),
          GoRoute(
            path: '/shop/catalog',
            name: 'shop-catalog',
            builder: (_, __) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/shop/product/:id',
            name: 'shop-product-detail',
            builder: (_, state) =>
                ProductPublicDetailScreen(productId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/shop/cart',
            name: 'shop-cart',
            builder: (_, __) => const CartScreen(),
          ),
          GoRoute(
            path: '/shop/orders',
            name: 'shop-orders',
            builder: (_, __) => const WholesalerOrdersScreen(),
          ),
          GoRoute(
            path: '/shop/orders/:id',
            name: 'shop-order-detail',
            builder: (_, state) =>
                WholesalerOrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/shop/profile',
            name: 'shop-profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Vendor (no shell yet)
      GoRoute(
        path: '/vendor/dashboard',
        builder: (_, __) => const _PlaceholderScreen(title: 'Vendor Dashboard'),
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(title)),
      );
}
