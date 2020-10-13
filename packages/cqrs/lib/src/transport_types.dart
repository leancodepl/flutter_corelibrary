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

/// Base class for contracts that can be serialized and sent to the backend.
abstract class CQRSMethod {
  /// Returns a JSON-encoded representation of the data this class carries.
  Map<String, dynamic> toJson();

  /// Returns a full name of this contractable, usually that is a fully
  /// qualified class name of the backend class.
  String getFullName();

  /// Returns a prefix applied before the full name of the contractable when
  /// sending a request to the backend.
  String pathPrefix;
}

/// Query describing a criteria for a query and the results it returns.
abstract class Query<T> implements CQRSMethod {
  /// Returns a result of type `T` deserialzied from the `json`.
  T resultFactory(dynamic json);

  @override
  String get pathPrefix => 'query';
}

/// Command carrying data related to performing a certain action on the backend.
abstract class Command implements CQRSMethod {
  @override
  String get pathPrefix => 'command';
}
