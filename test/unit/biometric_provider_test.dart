import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:local_auth/local_auth.dart';
import 'package:banabana_b2b/features/auth/providers/biometric_provider.dart';

class MockLocalAuth extends Mock implements LocalAuthentication {}

void main() {
  late MockLocalAuth mockAuth;

  setUp(() {
    mockAuth = MockLocalAuth();
    registerFallbackValue(const AuthenticationOptions());
  });

  group('BiometricService', () {
    test('isAvailable returns true when device supports biometrics', () async {
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => mockAuth.getAvailableBiometrics()).thenAnswer((_) async =>
          [BiometricType.fingerprint]);

      final service = BiometricService(auth: mockAuth);
      expect(await service.isAvailable(), true);
    });

    test('isAvailable returns false when device does not support biometrics', () async {
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => false);
      when(() => mockAuth.isDeviceSupported()).thenAnswer((_) async => false);

      final service = BiometricService(auth: mockAuth);
      expect(await service.isAvailable(), false);
    });

    test('authenticate returns true on success', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);

      final service = BiometricService(auth: mockAuth);
      expect(await service.authenticate(), true);
    });

    test('authenticate returns false on failure', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => false);

      final service = BiometricService(auth: mockAuth);
      expect(await service.authenticate(), false);
    });
  });
}
