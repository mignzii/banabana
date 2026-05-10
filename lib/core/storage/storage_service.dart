import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAccessToken  = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kUser         = 'user_json';
const _kLastPhone    = 'last_phone';
const _kBiometric    = 'biometric_enabled';

class StorageService {
  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> setAccessToken(String token) =>
      _secure.write(key: _kAccessToken, value: token);

  Future<String?> getAccessToken() =>
      _secure.read(key: _kAccessToken);

  Future<void> setRefreshToken(String token) =>
      _secure.write(key: _kRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _secure.read(key: _kRefreshToken);

  Future<void> clearAll() async {
    await _secure.delete(key: _kAccessToken);
    await _secure.delete(key: _kRefreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUser);
  }

  Future<void> setUserJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUser, json);
  }

  Future<String?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUser);
  }

  Future<void> setLastPhone(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastPhone, phone);
  }

  Future<String?> getLastPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastPhone);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometric, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometric) ?? false;
  }
}

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());
