import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late AuthRepository repo;

  setUp(() {
    dio = MockDio();
    repo = AuthRepository(dio: dio);
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('AuthRepository', () {
    test('requestOtp calls correct endpoint', () async {
      when(() => dio.post('/auth/otp/request', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'message': 'OTP envoyé', 'expiresIn': 300},
                statusCode: 200,
              ));

      await repo.requestOtp(phone: '+221771234567', role: 'producer');

      verify(() => dio.post('/auth/otp/request',
          data: {'phone': '+221771234567', 'role': 'producer'})).called(1);
    });

    test('verifyOtp returns AuthResponse on success', () async {
      final responseData = {
        'accessToken': 'access_123',
        'refreshToken': 'refresh_456',
        'user': {
          'id': 'u1',
          'phone': '+221771234567',
          'role': 'producer',
          'kycStatus': 'pending',
        },
      };

      when(() => dio.post('/auth/otp/verify', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: responseData,
                statusCode: 200,
              ));

      final result = await repo.verifyOtp(phone: '+221771234567', otp: '123456');

      expect(result.accessToken, 'access_123');
      expect(result.user.role, 'producer');
    });

    test('refreshToken returns new access token', () async {
      when(() => dio.post('/auth/refresh', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'accessToken': 'new_token'},
                statusCode: 200,
              ));

      final token = await repo.refreshToken('old_refresh');
      expect(token, 'new_token');
    });
  });
}
