import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/data/models/auth_response.dart';
import 'package:banabana_b2b/features/auth/data/models/user.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockStorageService mockStorage;
  late ProviderContainer container;

  const testUser = User(
    id: 'u1', phone: '+221771234567',
    role: 'producer', kycStatus: 'approved',
  );
  const testAuth = AuthResponse(
    accessToken: 'access', refreshToken: 'refresh', user: testUser,
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockStorageService();
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
      storageServiceProvider.overrideWithValue(mockStorage),
    ]);
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    test('initial state is unauthenticated', () {
      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });

    test('login stores tokens and sets user', () async {
      when(() => mockStorage.setAccessToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.setRefreshToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.setUserJson(any())).thenAnswer((_) async {});

      await container.read(authProvider.notifier).login(testAuth);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.user?.id, 'u1');
    });

    test('logout clears state and storage', () async {
      when(() => mockStorage.setAccessToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.setRefreshToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.setUserJson(any())).thenAnswer((_) async {});
      when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => 'refresh');
      when(() => mockRepo.logout(any())).thenAnswer((_) async {});
      when(() => mockStorage.clearAll()).thenAnswer((_) async {});

      await container.read(authProvider.notifier).login(testAuth);
      await container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });
  });
}
