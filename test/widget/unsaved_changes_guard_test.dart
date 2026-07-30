import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banabana_b2b/shared/widgets/unsaved_changes_guard.dart';

/// Deux routes : on ouvre la seconde, protégée par le garde, et on tente d'en
/// sortir comme le ferait le geste retour iOS (Navigator.maybePop).
Widget _app({required bool isDirty, required GlobalKey<NavigatorState> navKey}) {
  return MaterialApp(
    navigatorKey: navKey,
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UnsavedChangesGuard(
                  isDirty: isDirty,
                  child: const Scaffold(body: Text('formulaire')),
                ),
              ),
            ),
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  expect(find.text('formulaire'), findsOneWidget);
}

void main() {
  final navKey = GlobalKey<NavigatorState>();

  testWidgets('formulaire vierge : le retour sort directement',
      (tester) async {
    await tester.pumpWidget(_app(isDirty: false, navKey: navKey));
    await _openForm(tester);

    await navKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('formulaire'), findsNothing);
    expect(find.text('ouvrir'), findsOneWidget);
  });

  testWidgets('formulaire modifié : le retour demande confirmation',
      (tester) async {
    await tester.pumpWidget(_app(isDirty: true, navKey: navKey));
    await _openForm(tester);

    await navKey.currentState!.maybePop();
    await tester.pumpAndSettle();

    // On reste sur le formulaire, une confirmation est affichée
    expect(find.text('formulaire'), findsOneWidget);
    expect(find.text('Abandonner les modifications ?'), findsOneWidget);
  });

  testWidgets('« Continuer » garde l\'utilisateur sur le formulaire',
      (tester) async {
    await tester.pumpWidget(_app(isDirty: true, navKey: navKey));
    await _openForm(tester);

    await navKey.currentState!.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('formulaire'), findsOneWidget);
    expect(find.text('Abandonner les modifications ?'), findsNothing);
  });

  testWidgets('« Abandonner » quitte réellement le formulaire',
      (tester) async {
    await tester.pumpWidget(_app(isDirty: true, navKey: navKey));
    await _openForm(tester);

    await navKey.currentState!.maybePop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonner'));
    await tester.pumpAndSettle();

    expect(find.text('formulaire'), findsNothing);
    expect(find.text('ouvrir'), findsOneWidget);
  });

  testWidgets('confirmLeave() sert aussi les boutons retour de l\'AppBar',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: Text('écran'));
      }),
    ));

    final future = UnsavedChangesGuard.confirmLeave(ctx);
    await tester.pumpAndSettle();
    expect(find.text('Abandonner les modifications ?'), findsOneWidget);

    await tester.tap(find.text('Abandonner'));
    await tester.pumpAndSettle();
    expect(await future, isTrue);
  });
}
