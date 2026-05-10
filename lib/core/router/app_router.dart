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

String _roleHome(String? role) {
  return switch (role) {
    'producer'   => '/producer/dashboard',
    'wholesaler' => '/shop/home',
    'vendor'     => '/vendor/dashboard',
    _            => '/auth/login',
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
      GoRoute(path: '/auth/login',   builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/otp',     builder: (_, state) {
        final extra = state.extra as Map<String, String>;
        return OtpScreen(phone: extra['phone']!, role: extra['role']!);
      }),
      GoRoute(path: '/auth/register', builder: (_, state) {
        final phone = (state.extra as Map<String, String>)['phone']!;
        return RegisterScreen(phone: phone);
      }),
      GoRoute(path: '/auth/set-pin', builder: (_, state) {
        final phone = (state.extra as Map<String, String>)['phone']!;
        return SetPinScreen(phone: phone);
      }),
      GoRoute(path: '/auth/pin',     builder: (_, state) {
        final phone = (state.extra as Map<String, String>)['phone']!;
        return PinLoginScreen(phone: phone);
      }),
      GoRoute(path: '/auth/kyc',     builder: (_, __) => const KycScreen()),

      GoRoute(
        path: '/producer/dashboard',
        builder: (_, __) => const _PlaceholderScreen(title: 'Producer Dashboard'),
      ),
      GoRoute(
        path: '/shop/home',
        builder: (_, __) => const _PlaceholderScreen(title: 'Shop Home'),
      ),
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
