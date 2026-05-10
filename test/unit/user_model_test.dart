import 'package:flutter_test/flutter_test.dart';
import 'package:banabana_b2b/features/auth/data/models/user.dart';

void main() {
  group('User model', () {
    final json = {
      'id': 'user_123',
      'phone': '+221771234567',
      'role': 'producer',
      'firstName': 'Amadou',
      'lastName': 'Diallo',
      'email': 'amadou@test.com',
      'kycStatus': 'approved',
    };

    test('fromJson deserializes correctly', () {
      final user = User.fromJson(json);
      expect(user.id, 'user_123');
      expect(user.phone, '+221771234567');
      expect(user.role, 'producer');
      expect(user.kycStatus, 'approved');
    });

    test('toJson round-trip preserves all fields', () {
      final user = User.fromJson(json);
      final result = user.toJson();
      expect(result['id'], 'user_123');
      expect(result['role'], 'producer');
      expect(result['kycStatus'], 'approved');
    });

    test('copyWith changes only specified fields', () {
      final user = User.fromJson(json);
      final updated = user.copyWith(firstName: 'Moussa');
      expect(updated.firstName, 'Moussa');
      expect(updated.id, 'user_123');
    });

    test('two users with same data are equal', () {
      final a = User.fromJson(json);
      final b = User.fromJson(json);
      expect(a, equals(b));
    });
  });
}
