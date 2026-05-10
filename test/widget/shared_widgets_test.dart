import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banabana_b2b/shared/widgets/empty_state_widget.dart';
import 'package:banabana_b2b/shared/widgets/error_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('affiche le titre et le sous-titre', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            title: 'Aucune commande',
            subtitle: 'Vos commandes apparaîtront ici.',
          ),
        ),
      ));
      expect(find.text('Aucune commande'), findsOneWidget);
      expect(find.text('Vos commandes apparaîtront ici.'), findsOneWidget);
    });

    testWidgets('affiche le bouton CTA quand fourni', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            title: 'Vide',
            subtitle: 'Rien ici',
            ctaLabel: 'Ajouter',
            onCta: () => tapped = true,
          ),
        ),
      ));
      await tester.tap(find.text('Ajouter'));
      expect(tapped, true);
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('affiche message erreur et bouton réessayer', (tester) async {
      var retried = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ErrorStateWidget(
            message: 'Connexion perdue',
            onRetry: () => retried = true,
          ),
        ),
      ));
      expect(find.text('Connexion perdue'), findsOneWidget);
      await tester.tap(find.text('Réessayer'));
      expect(retried, true);
    });
  });
}
