import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/features/auth/screens/pin_login_screen.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  testWidgets('affiche 4 cercles PIN vides au démarrage', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: PinLoginScreen(phone: '+221771234567'),
      ),
    ));
    expect(find.byType(PinDot), findsNWidgets(4));
  });

  testWidgets('le bouton biométrique est masqué si non disponible', (tester) async {
    final mockStorage = MockStorageService();
    when(() => mockStorage.isBiometricEnabled()).thenAnswer((_) async => false);

    await tester.pumpWidget(ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(mockStorage)],
      child: const MaterialApp(home: PinLoginScreen(phone: '+221771234567')),
    ));
    await tester.pump();
    expect(find.byKey(const Key('biometric_button')), findsNothing);
  });
}
