// Copyright 2021 LeanCode Sp. z o.o.
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

import 'package:login_client/login_client.dart';

/// A `flutter_secure_storage` implementation of the [CredentialsStorage].
class FlutterSecureCredentialsStorage implements CredentialsStorage {
  /// Creates the [CredentialsStorage].
  const FlutterSecureCredentialsStorage();

  @override
  Future<Credentials?> read() async {
    throw UnsupportedError('Cannot read credentials storage');
  }

  @override
  Future<void> save(Credentials credentials) {
    throw UnsupportedError('Cannot save credentials storage');
  }

  @override
  Future<void> clear() {
    throw UnsupportedError('Cannot clear credentials storage');
  }
}
