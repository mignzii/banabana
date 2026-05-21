import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';
import 'package:banabana_b2b/core/api/auth_interceptor.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://3.227.108.30/v1',
);

/// Resolves a possibly-relative image URL from the backend.
/// TypeORM uploads return paths like "/uploads/xxx.jpg" — prefix with the server origin.
String resolveImageUrl(String url) {
  if (url.startsWith('/')) {
    final origin = _kBaseUrl.replaceFirst(RegExp(r'/v1.*'), '');
    return '$origin$url';
  }
  return url;
}

final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.read(storageServiceProvider);
  final interceptor = AuthInterceptor(storage: storage);

  final dio = Dio(BaseOptions(
    baseUrl: _kBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ))
    ..transformer = SyncTransformer();

  interceptor.setDio(dio);
  dio.interceptors.add(interceptor);

  return dio;
});
