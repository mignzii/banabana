import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:banabana_b2b/core/router/app_router.dart';
import 'package:banabana_b2b/core/theme/app_theme.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/auth/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkStoredAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'BanaBana Pro',
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
