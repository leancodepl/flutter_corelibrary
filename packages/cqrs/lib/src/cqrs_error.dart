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

/// Error types that are recognized by Cqrs.
enum CqrsError {
  /// Represents a network/socket error
  network,

  /// Represents a HTTP 401 authetication error
  authentication,

  /// Represents a HTTP 403 forbidden access error
  forbiddenAccess,

  /// Represents a HTTP 422 validation error
  validation,

  /// Represents a generic error which covers all remaining errors
  unknown,
}
