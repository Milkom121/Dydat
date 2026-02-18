import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dydat/services/storage_service.dart';

/// In-memory FlutterSecureStorage for testing.
class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.clear();
  }
}

void main() {
  late StorageService service;
  late FakeSecureStorage fakeStorage;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    service = StorageService(storage: fakeStorage);
  });

  group('StorageService', () {
    test('saveAccessToken and getAccessToken roundtrip', () async {
      expect(await service.getAccessToken(), isNull);
      await service.saveAccessToken('test-token-123');
      expect(await service.getAccessToken(), 'test-token-123');
    });

    test('deleteAccessToken removes token', () async {
      await service.saveAccessToken('token');
      await service.deleteAccessToken();
      expect(await service.getAccessToken(), isNull);
    });

    test('saveUtenteTempId and getUtenteTempId roundtrip', () async {
      expect(await service.getUtenteTempId(), isNull);
      await service.saveUtenteTempId('temp-uuid-456');
      expect(await service.getUtenteTempId(), 'temp-uuid-456');
    });

    test('deleteUtenteTempId removes ID', () async {
      await service.saveUtenteTempId('temp-uuid');
      await service.deleteUtenteTempId();
      expect(await service.getUtenteTempId(), isNull);
    });

    test('clearAll removes everything', () async {
      await service.saveAccessToken('token');
      await service.saveUtenteTempId('temp');
      await service.clearAll();
      expect(await service.getAccessToken(), isNull);
      expect(await service.getUtenteTempId(), isNull);
    });
  });
}
