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

import 'package:oauth2/oauth2.dart' as oauth2;

/// An interface describing the storage for [oauth2.Credentials].
abstract class CredentialsStorage {
  /// Get saved [oauth2.Credentials] or null when none could be found.
  Future<oauth2.Credentials> read();

  /// Save `credentials` to the storage.
  Future<void> save(oauth2.Credentials credentials);

  /// Remove the [oauth2.Credentials] from the storage.
  Future<void> clear();
}
