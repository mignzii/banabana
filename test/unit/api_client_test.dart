import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/core/api/auth_interceptor.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

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
  });
}

class RequestInterceptorHandlerFake extends Fake
    implements RequestInterceptorHandler {
  @override
  void next(RequestOptions requestOptions) {}
}
