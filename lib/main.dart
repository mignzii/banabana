import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/theme/app_theme.dart';
import 'package:banabana_b2b/features/auth/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: BanaBanaApp()));
}

class BanaBanaApp extends ConsumerWidget {
  const BanaBanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'BanaBana Business',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      // TODO: replace with MaterialApp.router once appRouterProvider is ready (Task 9)
      home: const Scaffold(body: Center(child: Text('BanaBana B2B'))),
      debugShowCheckedModeBanner: false,
    );
  }
}
