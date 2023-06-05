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

/// An interface for contracts that can be serialized and sent to the backend.
abstract interface class CqrsMethod {
  /// Returns a JSON-encoded representation of the data this class carries.
  Map<String, dynamic> toJson();

  /// Returns a full name of this CQRS method, usually that is a fully
  /// qualified class name of the backend class.
  String getFullName();
}

/// Query describing a criteria for a query and the results it returns.
abstract interface class Query<T> extends CqrsMethod {
  /// Returns a result of type `T` deserialzied from the `json`.
  T resultFactory(dynamic json);
}

/// Command carrying data related to performing a certain action on the backend.
abstract interface class Command extends CqrsMethod {}

/// Operation describing a criteria for a query, a command, and the results it returns.
abstract interface class Operation<T> extends CqrsMethod {
  /// Returns a result of type `T` deserialzied from the `json`.
  T resultFactory(dynamic json);
}
