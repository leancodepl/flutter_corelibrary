// Copyright 2023 LeanCode Sp. z o.o.
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

/// An exception that occurs when there is some problem with refreshing
/// the credentials.
class RefreshException implements Exception {
  /// Creates the [RefreshException] with a [message].
  const RefreshException(this.message);

  /// The exception message.
  final String message;

  @override
  String toString() => 'RefreshException: $message';
}
