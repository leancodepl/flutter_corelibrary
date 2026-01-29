import 'package:flutter_test/flutter_test.dart';
import 'package:login_client_flutter/login_client_flutter.dart';
// for testing credentials
// ignore: depend_on_referenced_packages
import 'package:oauth2/oauth2.dart';

// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

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
    return _storage[key];
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
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
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
    _storage.remove(key);
  }
}

void main() {
  group('FlutterSecureCredentialsStorage', () {
    test('uses default storage when none provided', () {
      const storage = FlutterSecureCredentialsStorage();

      expect(storage, isA<FlutterSecureCredentialsStorage>());
    });

    test('accepts custom storage instance', () {
      final customStorage = MockFlutterSecureStorage();
      final storage = FlutterSecureCredentialsStorage(storage: customStorage);

      expect(storage, isA<FlutterSecureCredentialsStorage>());
    });

    test('works with custom storage - read/write/clear operations', () async {
      final customStorage = MockFlutterSecureStorage();
      final storage = FlutterSecureCredentialsStorage(storage: customStorage);

      expect(await storage.read(), null);

      final credentials = Credentials('test_token');
      await storage.save(credentials);

      final readCredentials = await storage.read();
      expect(readCredentials?.accessToken, equals('test_token'));

      await storage.clear();
      expect(await storage.read(), null);
    });
  });
}
