import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() {
    // Mock flutter_secure_storage
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall call) async => null,
    );
    // Mock shared_preferences
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
  });

  group('StorageService', () {
    test('stores and retrieves access token', () async {
      await storage.setAccessToken('token_abc');
      expect(await storage.getAccessToken(), isA<String?>());
    });

    test('stores and retrieves refresh token', () async {
      await storage.setRefreshToken('refresh_xyz');
      expect(await storage.getRefreshToken(), isA<String?>());
    });

    test('isBiometricEnabled defaults to false', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await storage.isBiometricEnabled(), false);
    });

    test('setBiometricEnabled persists value', () async {
      SharedPreferences.setMockInitialValues({});
      await storage.setBiometricEnabled(true);
      expect(await storage.isBiometricEnabled(), true);
    });

    test('setLastPhone and getLastPhone round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      await storage.setLastPhone('+221771234567');
      expect(await storage.getLastPhone(), '+221771234567');
    });

    test('getUserJson returns null when not set', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await storage.getUserJson(), isNull);
    });

    test('setUserJson and getUserJson round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      await storage.setUserJson('{"id":"1"}');
      expect(await storage.getUserJson(), '{"id":"1"}');
    });
  });
}
