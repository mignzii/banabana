import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class BiometricService {
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Utilisez votre biométrie pour vous connecter',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

class BiometricState {
  const BiometricState({
    this.isAvailable = false,
    this.isEnabled = false,
  });
  final bool isAvailable;
  final bool isEnabled;
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  BiometricNotifier({
    required this.service,
    required this.storage,
  }) : super(const BiometricState());

  final BiometricService service;
  final StorageService storage;

  Future<void> initialize() async {
    final available = await service.isAvailable();
    final enabled = available && await storage.isBiometricEnabled();
    state = BiometricState(isAvailable: available, isEnabled: enabled);
  }

  Future<bool> authenticate() => service.authenticate();

  Future<void> setEnabled(bool enabled) async {
    await storage.setBiometricEnabled(enabled);
    state = BiometricState(isAvailable: state.isAvailable, isEnabled: enabled);
  }
}

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier(
    service: BiometricService(),
    storage: ref.read(storageServiceProvider),
  );
});
