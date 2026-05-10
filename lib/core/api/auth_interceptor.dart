import 'package:dio/dio.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage});

  final StorageService storage;
  Dio? _dio;

  void setDio(Dio dio) => _dio = dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && _dio != null) {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        handler.next(err);
        return;
      }
      try {
        final response = await _dio!.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {}),
        );
        final newToken = response.data['accessToken'] as String;
        await storage.setAccessToken(newToken);
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio!.fetch(retryOptions);
        handler.resolve(retryResponse);
      } catch (_) {
        await storage.clearAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
