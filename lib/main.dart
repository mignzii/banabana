import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: BanaBanaApp()));
}

class BanaBanaApp extends StatelessWidget {
  const BanaBanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanaBana Business',
      theme: ThemeData(useMaterial3: true),
      // TODO: replace with MaterialApp.router once appRouterProvider is ready (Task 9)
      home: const Scaffold(body: Center(child: Text('BanaBana B2B'))),
      debugShowCheckedModeBanner: false,
    );
  }
}
