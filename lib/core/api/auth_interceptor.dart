import 'package:dio/dio.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.storage});

  final StorageService storage;
  Dio? _dio;

  static const _retryKey = '_auth_retry_attempted';

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
    final alreadyRetried = err.requestOptions.extra[_retryKey] == true;
    if (err.response?.statusCode == 401 && _dio != null && !alreadyRetried) {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null) {
        handler.next(err);
        return;
      }
      try {
        // Use a clean Dio instance (no interceptors) to avoid circular refresh calls
        final refreshDio = Dio(BaseOptions(
          baseUrl: _dio!.options.baseUrl,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final newToken = response.data['accessToken'] as String;
        await storage.setAccessToken(newToken);
        final retryOptions = err.requestOptions.copyWith(
          headers: {
            ...err.requestOptions.headers,
            'Authorization': 'Bearer $newToken',
          },
          extra: {
            ...err.requestOptions.extra,
            _retryKey: true,
          },
        );
        final retryResponse = await _dio!.fetch(retryOptions);
        handler.resolve(retryResponse);
      } on DioException catch (e) {
        await storage.clearAll();
        handler.next(e);
      } catch (e) {
        await storage.clearAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
