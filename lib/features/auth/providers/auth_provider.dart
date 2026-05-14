import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banabana_b2b/features/auth/data/auth_repository.dart';
import 'package:banabana_b2b/features/auth/data/models/auth_response.dart';
import 'package:banabana_b2b/features/auth/data/models/user.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.needsPinUnlock = false,
    this.pendingPhone,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  final bool isAuthenticated;
  final bool isLoading;
  final bool needsPinUnlock;
  final String? pendingPhone;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? needsPinUnlock,
    String? pendingPhone,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? error,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        needsPinUnlock: needsPinUnlock ?? this.needsPinUnlock,
        pendingPhone: pendingPhone ?? this.pendingPhone,
        user: user ?? this.user,
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
        error: error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.repo, required this.storage})
      : super(const AuthState());

  final AuthRepository repo;
  final StorageService storage;

  /// Called at app startup — restores "locked" state if tokens exist.
  /// Does NOT auto-authenticate; the user must re-enter their PIN.
  Future<void> checkStoredAuth() async {
    state = state.copyWith(isLoading: true);
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    final lastPhone = await storage.getLastPhone();

    if (accessToken != null && refreshToken != null && lastPhone != null) {
      state = AuthState(
        isLoading: false,
        needsPinUnlock: true,
        pendingPhone: lastPhone,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  /// Called from biometric auth — re-authenticates via stored tokens.
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    final userJson = await storage.getUserJson();

    if (accessToken != null && refreshToken != null && userJson != null) {
      try {
        final freshUser = await repo.getProfile();
        await storage.setUserJson(jsonEncode(freshUser.toJson()));
        state = AuthState(
          isAuthenticated: true,
          isLoading: false,
          user: freshUser,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } catch (_) {
        await storage.clearAll();
        state = const AuthState();
      }
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  /// Clears stored auth — called when user cancels PIN unlock screen.
  Future<void> cancelPinUnlock() async {
    await storage.clearAll();
    state = const AuthState();
  }

  Future<void> login(AuthResponse auth) async {
    await storage.setAccessToken(auth.accessToken);
    await storage.setRefreshToken(auth.refreshToken);
    await storage.setUserJson(jsonEncode(auth.user.toJson()));
    state = AuthState(
      isAuthenticated: true,
      user: auth.user,
      accessToken: auth.accessToken,
      refreshToken: auth.refreshToken,
    );
  }

  Future<void> logout() async {
    final rt = state.refreshToken ?? await storage.getRefreshToken();
    if (rt != null) {
      try { await repo.logout(rt); } catch (_) {}
    }
    await storage.clearAll();
    state = const AuthState();
  }

  Future<void> refreshProfile() async {
    try {
      final freshUser = await repo.getProfile();
      await storage.setUserJson(jsonEncode(freshUser.toJson()));
      state = state.copyWith(user: freshUser);
    } catch (_) {}
  }

  Future<void> updateProfile({String? email, String? firstName, String? lastName}) async {
    final updated = await repo.updateProfile(email: email, firstName: firstName, lastName: lastName);
    await storage.setUserJson(jsonEncode(updated.toJson()));
    state = state.copyWith(user: updated);
  }

  void setError(String message) {
    state = state.copyWith(error: message);
  }

  void clearError() {
    state = AuthState(
      isAuthenticated: state.isAuthenticated,
      isLoading: state.isLoading,
      user: state.user,
      accessToken: state.accessToken,
      refreshToken: state.refreshToken,
      error: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repo: ref.read(authRepositoryProvider),
    storage: ref.read(storageServiceProvider),
  );
});
