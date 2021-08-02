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

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:login_client/login_client.dart';

/// A `flutter_secure_storage` implementation of the [CredentialsStorage].
class MobileWebCredentialsStorage implements CredentialsStorage {
  /// Creates the [MobileWebCredentialsStorage].
  const MobileWebCredentialsStorage();

  @override
  Future<void> clear() async {
    window.localStorage.remove('credentials');
  }

  @override
  Future<Credentials?> read() async {
    final json = window.localStorage['credentials'];
    if (json != null) {
      return Credentials.fromJson(json);
    } else {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) async {
    final json = credentials.toJson();
    window.localStorage['credentials'] = json;
  }
}
