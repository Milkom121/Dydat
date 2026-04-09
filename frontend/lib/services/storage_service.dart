import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _keyAccessToken = 'access_token';
  static const _keyUtenteTempId = 'utente_temp_id';
  static const _keyOnboardingSessioneId = 'onboarding_sessione_id';

  final FlutterSecureStorage _storage;

  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Access Token
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _keyAccessToken, value: token);

  Future<void> deleteAccessToken() => _storage.delete(key: _keyAccessToken);

  // Utente Temp ID (onboarding flow)
  Future<String?> getUtenteTempId() => _storage.read(key: _keyUtenteTempId);

  Future<void> saveUtenteTempId(String id) =>
      _storage.write(key: _keyUtenteTempId, value: id);

  Future<void> deleteUtenteTempId() => _storage.delete(key: _keyUtenteTempId);

  // Onboarding Sessione ID (per ripresa dopo skip/interruzione)
  Future<String?> getOnboardingSessioneId() =>
      _storage.read(key: _keyOnboardingSessioneId);

  Future<void> saveOnboardingSessioneId(String id) =>
      _storage.write(key: _keyOnboardingSessioneId, value: id);

  Future<void> deleteOnboardingSessioneId() =>
      _storage.delete(key: _keyOnboardingSessioneId);

  // Clear all
  Future<void> clearAll() => _storage.deleteAll();
}
