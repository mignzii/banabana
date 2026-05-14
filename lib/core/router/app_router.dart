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
import 'package:banabana_b2b/features/auth/screens/quick_register_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/analytics_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/categories_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/inventory_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/messages_stub_screen.dart';
import 'package:banabana_b2b/features/producer/presentation/screens/conversation_screen.dart';
import 'package:banabana_b2b/features/producer/data/models/message_mock.dart';
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
import 'package:banabana_b2b/features/wholesaler/presentation/screens/search_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/wholesaler_orders_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/wholesaler_order_detail_screen.dart';
import 'package:banabana_b2b/features/wholesaler/presentation/screens/checkout_screen.dart';
import 'package:banabana_b2b/core/widgets/producer_shell.dart';
import 'package:banabana_b2b/core/widgets/wholesaler_shell.dart';
import 'package:banabana_b2b/shared/screens/profile_screen.dart';

final _rootNavKey        = GlobalKey<NavigatorState>(debugLabel: 'root');
final _producerShellKey  = GlobalKey<NavigatorState>(debugLabel: 'producerShell');
final _wholesalerShellKey = GlobalKey<NavigatorState>(debugLabel: 'wholesalerShell');

Page<void> _fadePage(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
  transitionDuration: const Duration(milliseconds: 200),
);

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
    navigatorKey: _rootNavKey,
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
      GoRoute(path: '/auth/login', pageBuilder: (_, __) => _fadePage(const LoginScreen())),
      GoRoute(
        path: '/auth/otp',
        pageBuilder: (_, state) {
          final extra = state.extra as Map<String, String>;
          return _fadePage(OtpScreen(phone: extra['phone']!, role: extra['role']!));
        },
      ),
      GoRoute(
        path: '/auth/register',
        pageBuilder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return _fadePage(RegisterScreen(phone: phone));
        },
      ),
      GoRoute(
        path: '/auth/set-pin',
        pageBuilder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return _fadePage(SetPinScreen(phone: phone));
        },
      ),
      GoRoute(
        path: '/auth/pin',
        pageBuilder: (_, state) {
          final phone = (state.extra as Map<String, String>)['phone']!;
          return _fadePage(PinLoginScreen(phone: phone));
        },
      ),
      GoRoute(
        path: '/auth/quick-register',
        pageBuilder: (_, __) => _fadePage(const QuickRegisterScreen()),
      ),

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
            pageBuilder: (_, __) => _fadePage(const ProducerHomeScreen()),
          ),
          GoRoute(
            path: '/producer/dashboard',
            name: 'producer-dashboard',
            pageBuilder: (_, __) => _fadePage(const ProducerDashboardScreen()),
          ),
          GoRoute(
            path: '/producer/products',
            name: 'producer-products',
            pageBuilder: (_, __) => _fadePage(const ProductsScreen()),
          ),
          GoRoute(
            path: '/producer/orders',
            name: 'producer-orders',
            pageBuilder: (_, __) => _fadePage(const OrdersScreen()),
          ),
          GoRoute(
            path: '/producer/inventory',
            name: 'producer-inventory',
            pageBuilder: (_, __) => _fadePage(const InventoryScreen()),
          ),
          GoRoute(
            path: '/producer/analytics',
            name: 'producer-analytics',
            pageBuilder: (_, __) => _fadePage(const AnalyticsScreen()),
          ),
          GoRoute(
            path: '/producer/messages',
            name: 'producer-messages',
            pageBuilder: (_, __) => _fadePage(const MessagesStubScreen()),
          ),
          GoRoute(
            path: '/producer/profile',
            name: 'producer-profile',
            pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
          ),
        ],
      ),

      // Producer full-screen routes (over shell, no bottom nav)
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/products/new',
        name: 'producer-product-new',
        pageBuilder: (_, __) => _fadePage(const ProductFormScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/products/:id',
        name: 'producer-product-detail',
        pageBuilder: (_, state) =>
            _fadePage(ProductDetailScreen(productId: state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/products/:id/edit',
        name: 'producer-product-edit',
        pageBuilder: (_, state) =>
            _fadePage(ProductFormScreen(productId: state.pathParameters['id'])),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/orders/:id',
        name: 'producer-order-detail',
        pageBuilder: (_, state) =>
            _fadePage(OrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/categories',
        name: 'producer-categories',
        pageBuilder: (_, __) => _fadePage(const CategoriesScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/producer/messages/:conversationId',
        name: 'producer-conversation',
        pageBuilder: (_, state) => _fadePage(
          ConversationScreen(
            conversationId: state.pathParameters['conversationId']!,
            conversation: state.extra as MockConversation?,
          ),
        ),
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
            pageBuilder: (_, __) => _fadePage(const ShopHomeScreen()),
          ),
          GoRoute(
            path: '/shop/dashboard',
            name: 'shop-dashboard',
            pageBuilder: (_, __) => _fadePage(const ShopDashboardScreen()),
          ),
          GoRoute(
            path: '/shop/catalog',
            name: 'shop-catalog',
            pageBuilder: (_, __) => _fadePage(const CatalogScreen()),
          ),
          GoRoute(
            path: '/shop/inventory',
            name: 'shop-inventory',
            pageBuilder: (_, __) => _fadePage(
              const ProductsScreen(routePrefix: '/shop/inventory'),
            ),
          ),
          GoRoute(
            path: '/shop/orders',
            name: 'shop-orders',
            pageBuilder: (_, __) => _fadePage(const WholesalerOrdersScreen()),
          ),
          GoRoute(
            path: '/shop/profile',
            name: 'shop-profile',
            pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
          ),
        ],
      ),

      // Wholesaler full-screen routes (over shell, no bottom nav)
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/product/:id',
        name: 'shop-product-detail',
        pageBuilder: (_, state) =>
            _fadePage(ProductPublicDetailScreen(productId: state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/cart',
        name: 'shop-cart',
        pageBuilder: (_, __) => _fadePage(const CartScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/search',
        name: 'shop-search',
        pageBuilder: (_, __) => _fadePage(const SearchScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/checkout',
        name: 'shop-checkout',
        pageBuilder: (_, __) => _fadePage(const CheckoutScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/orders/:id',
        name: 'shop-order-detail',
        pageBuilder: (_, state) =>
            _fadePage(WholesalerOrderDetailScreen(orderId: state.pathParameters['id']!)),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/inventory/new',
        name: 'shop-inventory-new',
        pageBuilder: (_, __) => _fadePage(const ProductFormScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/inventory/:id',
        name: 'shop-inventory-detail',
        pageBuilder: (_, state) => _fadePage(
          ProductDetailScreen(
            productId: state.pathParameters['id']!,
            routePrefix: '/shop/inventory',
          ),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/shop/inventory/:id/edit',
        name: 'shop-inventory-edit',
        pageBuilder: (_, state) => _fadePage(
          ProductFormScreen(productId: state.pathParameters['id']),
        ),
      ),

      // KYC — route protégée (accessible uniquement si authentifié)
      GoRoute(
        parentNavigatorKey: _rootNavKey,
        path: '/kyc',
        name: 'kyc',
        pageBuilder: (_, __) => _fadePage(const KycScreen()),
      ),

      // Vendor (no shell yet)
      GoRoute(
        path: '/vendor/dashboard',
        pageBuilder: (_, __) => _fadePage(const _PlaceholderScreen(title: 'Vendor Dashboard')),
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
