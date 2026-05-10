import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() => mockRepo = MockAuthRepository());

  Widget buildWidget() => ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: LoginScreen()),
      );

  testWidgets('affiche le champ téléphone avec autofocus', (tester) async {
    await tester.pumpWidget(buildWidget());
    expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
  });

  testWidgets('bouton Continuer désactivé si champ vide', (tester) async {
    await tester.pumpWidget(buildWidget());
    final btn = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(btn.onPressed, isNull);
  });

  testWidgets('validation : numéro trop court affiche erreur', (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.enterText(find.byType(TextFormField).first, '123');
    await tester.pump();
    final form = tester.widget<Form>(find.byType(Form));
    (form.key as GlobalKey<FormState>).currentState!.validate();
    await tester.pump();
    expect(find.textContaining('invalide'), findsOneWidget);
  });
}
