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

import 'cqrs_result.dart';

/// Abstract class for CQRS result handlers. Can be used to specify certain
/// behaviors that will be triggered for given errors i.e. showing snackbar
/// on network error or logging out on authetication error etc.
abstract class CqrsMiddleware {
  /// Creates [CqrsMiddleware] class.
  const CqrsMiddleware();

  /// Handle and return query result. If no modification of given result
  /// is needed then return the same `result` that was passed to the method.
  Future<QResult<T>> handleQueryResult<T>(
    QResult<T> result,
  ) =>
      Future.value(result);

  /// Handle and return command result. If no modification of given result
  /// is needed then return the same `result` that was passed to the method.
  Future<CResult> handleCommandResult(
    CResult result,
  ) =>
      Future.value(result);

  /// Handle and return operation result. If no modification of given result
  /// is needed then return the same `result` that was passed to the method.
  Future<CqrsOperationResult<T>> handleOperationResult<T>(
    CqrsOperationResult<T> result,
  ) =>
      Future.value(result);
}
