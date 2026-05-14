import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StorageService — kycSubmittedLocally', () {
    test('returns false by default', () async {
      final storage = StorageService();
      expect(await storage.getKycSubmittedLocally(), false);
    });

    test('returns true after setting to true', () async {
      final storage = StorageService();
      await storage.setKycSubmittedLocally(true);
      expect(await storage.getKycSubmittedLocally(), true);
    });

    test('can be reset to false', () async {
      final storage = StorageService();
      await storage.setKycSubmittedLocally(true);
      await storage.setKycSubmittedLocally(false);
      expect(await storage.getKycSubmittedLocally(), false);
    });
  });
}
