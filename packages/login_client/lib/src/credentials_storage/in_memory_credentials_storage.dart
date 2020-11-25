import 'package:oauth2/oauth2.dart' as oauth2;

import 'credentials_storage.dart';

class InMemoryCredentialsStorage extends CredentialsStorage {
  oauth2.Credentials _credentials;

  @override
  Future<oauth2.Credentials> read() async {
    return _credentials;
  }

  @override
  Future<void> save(oauth2.Credentials credentials) async {
    _credentials = credentials;
  }

  @override
  Future<void> clear() async {
    _credentials = null;
  }
}
