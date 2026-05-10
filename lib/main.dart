import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BanaBanaApp()));
}

class BanaBanaApp extends ConsumerWidget {
  const BanaBanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BanaBana Business',
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(body: Center(child: Text('BanaBana B2B'))),
      debugShowCheckedModeBanner: false,
    );
  }
}
