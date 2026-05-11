import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/features/auth/data/models/auth_response.dart';
import 'package:banabana_b2b/features/auth/data/models/user.dart';

class AuthRepository {
  AuthRepository({required this.dio});
  final Dio dio;

  Future<void> requestOtp({
    required String phone,
    required String role,
  }) async {
    await dio.post('/auth/otp/request', data: {'phone': phone, 'role': role});
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await dio.post('/auth/otp/verify',
        data: {'phone': phone, 'otp': otp});
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setPin({
    required String phone,
    required String pin,
  }) async {
    await dio.post('/auth/pin/set', data: {'pin': pin});
  }

  Future<AuthResponse> verifyPin({
    required String phone,
    required String pin,
  }) async {
    final res = await dio.post('/auth/pin/verify',
        data: {'phone': phone, 'pin': pin});
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<String> refreshToken(String refreshToken) async {
    final res = await dio.post('/auth/refresh',
        data: {'refreshToken': refreshToken});
    return res.data['accessToken'] as String;
  }

  Future<void> logout(String refreshToken) async {
    await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<User> getProfile() async {
    final res = await dio.get('/users/profile');
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> submitKyc({
    required String frontPath,
    required String backPath,
  }) async {
    final formData = FormData.fromMap({
      'frontDocument': await MultipartFile.fromFile(frontPath),
      'backDocument': await MultipartFile.fromFile(backPath),
    });
    await dio.post('/users/kyc', data: formData);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(dio: ref.read(apiClientProvider));
});
