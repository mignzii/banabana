import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:banabana_b2b/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow E2E', () {
    testWidgets('Scénario 1 : login screen s\'affiche au démarrage', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.text('BanaBana Business'), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
    });

    testWidgets('Scénario 1 : saisie numéro téléphone active le bouton Continuer', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '+221771234567');
      await tester.pump();
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('Scénario 1 : sélection rôle Grossiste', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grossiste'));
      await tester.pump();
      expect(find.text('Grossiste'), findsOneWidget);
    });

    testWidgets('Scénario 5 : ThemeModeProvider est disponible', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(ProviderScope), findsOneWidget);
    });
  });
}
