import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/core/api/auth_interceptor.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

DioException _make401(RequestOptions options) => DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 401,
        statusMessage: 'Unauthorized',
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  group('AuthInterceptor', () {
    late MockStorageService storage;
    late AuthInterceptor interceptor;

    setUp(() {
      storage = MockStorageService();
      interceptor = AuthInterceptor(storage: storage);
    });

    test('adds Authorization header when token exists', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'test_token');

      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandlerFake();
      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_token');
    });

    test('does not add Authorization header when no token', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/test');
      final handler = RequestInterceptorHandlerFake();
      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], isNull);
    });

    test('onError forwards non-401 errors unchanged', () async {
      final options = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
        type: DioExceptionType.badResponse,
      );
      final handler = ErrorInterceptorHandlerFake();
      await interceptor.onError(err, handler);
      expect(handler.nextCalled, true);
      expect(handler.resolvedResponse, isNull);
    });

    test('onError on 401 without refreshToken clears nothing and forwards',
        () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => null);

      final options = RequestOptions(path: '/test');
      final handler = ErrorInterceptorHandlerFake();
      await interceptor.onError(_make401(options), handler);

      expect(handler.nextCalled, true);
      verifyNever(() => storage.clearAll());
    });
  });
}

class RequestInterceptorHandlerFake extends Fake
    implements RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}

class ErrorInterceptorHandlerFake extends Fake
    implements ErrorInterceptorHandler {
  bool nextCalled = false;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    nextCalled = true;
  }

  @override
  void resolve(Response<dynamic> response) {
    resolvedResponse = response;
  }
}
