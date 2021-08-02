// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:login_client/login_client.dart';

class LocalStorage extends CredentialsStorage {
  @override
  Future<void> clear() async {
    window.localStorage.remove('credentials');
  }

  @override
  Future<Credentials?> read() async {
    try {
      final json = window.localStorage['credentials'];
      if (json != null) {
        return Credentials.fromJson(json);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) async {
    final json = credentials.toJson();
    window.localStorage['credentials'] = json;
  }
}
