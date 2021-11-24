import 'package:login_client/src/credentials_storage/in_memory_credentials_storage.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryCredentialsStorage', () {
    late InMemoryCredentialsStorage storage;
    setUp(() => storage = InMemoryCredentialsStorage());

    test('reads null initially', () {
      expect(storage.read(), completion(null));
    });

    test('reads exactly what it saved', () async {
      final credentials = Credentials('test_token');

      await storage.save(credentials);

      expect(storage.read(), completion(credentials));
    });

    test('reads null after saving and clearing', () async {
      final credentials = Credentials('test_token');

      await storage.save(credentials);
      await storage.clear();

      expect(storage.read(), completion(null));
    });
  });
}
