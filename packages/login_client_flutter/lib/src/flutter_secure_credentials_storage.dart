// Copyright 2020 LeanCode Sp. z o.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:login_client/login_client.dart';
import 'package:oauth2/oauth2.dart';

/// A `flutter_secure_storage` implementation of the [CredentialsStorage].
class FlutterSecureCredentialsStorage implements CredentialsStorage {
  /// Creates the [CredentialsStorage].
  const FlutterSecureCredentialsStorage();

  static const _key = 'login_client_flutter_credentials';
  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  @override
  Future<Credentials> read() async {
    final json = await _storage.read(key: _key);
    if (json == null) {
      return null;
    }

    try {
      return Credentials.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) {
    return _storage.write(key: _key, value: credentials.toJson());
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
