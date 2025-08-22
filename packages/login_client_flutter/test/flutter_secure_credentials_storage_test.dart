import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_client_flutter/login_client_flutter.dart';
import 'package:oauth2/oauth2.dart';

// Mock FlutterSecureStorage for testing
class MockFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  const MockFlutterSecureStorage() : super();

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }
}

void main() {
  group('FlutterSecureCredentialsStorage', () {
    test('uses default storage when none provided', () {
      const storage = FlutterSecureCredentialsStorage();
      
      // This test ensures the constructor works with no parameters
      expect(storage, isA<FlutterSecureCredentialsStorage>());
    });

    test('accepts custom storage instance', () {
      const customStorage = MockFlutterSecureStorage();
      const storage = FlutterSecureCredentialsStorage(storage: customStorage);
      
      // This test ensures the constructor works with custom storage
      expect(storage, isA<FlutterSecureCredentialsStorage>());
    });

    test('works with custom storage - read/write/clear operations', () async {
      const customStorage = MockFlutterSecureStorage();
      const storage = FlutterSecureCredentialsStorage(storage: customStorage);
      
      // Test initial read returns null
      expect(await storage.read(), null);
      
      // Test saving and reading credentials
      final credentials = Credentials('test_token');
      await storage.save(credentials);
      
      final readCredentials = await storage.read();
      expect(readCredentials?.accessToken, equals('test_token'));
      
      // Test clearing
      await storage.clear();
      expect(await storage.read(), null);
    });

    test('maintains backward compatibility with default constructor', () async {
      // This test verifies that existing code continues to work
      const storage = FlutterSecureCredentialsStorage();
      
      // Should be able to perform operations without error
      expect(storage.read(), completes);
    });
  });
}