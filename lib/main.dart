import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:banabana_b2b/core/router/app_router.dart';
import 'package:banabana_b2b/core/theme/app_theme.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/auth/providers/theme_provider.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  runApp(const ProviderScope(child: BanaBanaApp()));
}

class BanaBanaApp extends ConsumerStatefulWidget {
  const BanaBanaApp({super.key});

  @override
  ConsumerState<BanaBanaApp> createState() => _BanaBanaAppState();
}

class _BanaBanaAppState extends ConsumerState<BanaBanaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    await ref.read(authProvider.notifier).initialize();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BanaBana Business',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
