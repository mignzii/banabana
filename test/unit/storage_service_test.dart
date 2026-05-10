import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;

  setUp(() {
    // In-memory mock for flutter_secure_storage
    final Map<String, String> secureStore = {};
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'write':
          final key = args['key'] as String;
          final value = args['value'] as String;
          secureStore[key] = value;
          return null;
        case 'read':
          final key = args['key'] as String;
          return secureStore[key];
        case 'delete':
          final key = args['key'] as String;
          secureStore.remove(key);
          return null;
        case 'deleteAll':
          secureStore.clear();
          return null;
        default:
          return null;
      }
    });
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
  });

  group('StorageService', () {
    test('stores and retrieves access token', () async {
      await storage.setAccessToken('token_abc');
      expect(await storage.getAccessToken(), 'token_abc');
    });

    test('stores and retrieves refresh token', () async {
      await storage.setRefreshToken('refresh_xyz');
      expect(await storage.getRefreshToken(), 'refresh_xyz');
    });

    test('returns null when access token not set', () async {
      expect(await storage.getAccessToken(), isNull);
    });

    test('isBiometricEnabled defaults to false', () async {
      expect(await storage.isBiometricEnabled(), false);
    });

    test('setBiometricEnabled persists value', () async {
      await storage.setBiometricEnabled(true);
      expect(await storage.isBiometricEnabled(), true);
    });

    test('setLastPhone and getLastPhone round-trip', () async {
      await storage.setLastPhone('+221771234567');
      expect(await storage.getLastPhone(), '+221771234567');
    });

    test('getUserJson returns null when not set', () async {
      expect(await storage.getUserJson(), isNull);
    });

    test('setUserJson and getUserJson round-trip', () async {
      await storage.setUserJson('{"id":"1"}');
      expect(await storage.getUserJson(), '{"id":"1"}');
    });

    test('clearAll removes tokens and user data', () async {
      await storage.setAccessToken('tok');
      await storage.setRefreshToken('ref');
      await storage.setUserJson('{"id":"1"}');
      await storage.setLastPhone('+221771234567');
      await storage.setBiometricEnabled(true);
      await storage.clearAll();
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getUserJson(), isNull);
      expect(await storage.getLastPhone(), isNull);
      expect(await storage.isBiometricEnabled(), false);
    });
  });
}
