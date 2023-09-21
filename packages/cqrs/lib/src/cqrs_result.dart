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

import 'package:equatable/equatable.dart';

import 'command_response.dart';
import 'cqrs_error.dart';

typedef QueryResult<T> = CqrsMethodResult<T, QueryErrorType>;
typedef QuerySuccess<T> = CqrsMethodSuccess<T, QueryErrorType>;
typedef QueryFailure<T> = CqrsMethodFailure<T, QueryErrorType>;

typedef CommandResult = CqrsMethodResult<void, CommandError>;
typedef CommandSuccess = CqrsMethodSuccess<void, CommandError>;
typedef CommandFailure = CqrsMethodFailure<void, CommandError>;

typedef OperationResult<T> = CqrsMethodResult<T, OperationErrorType>;
typedef OperationSuccess<T> = CqrsMethodSuccess<T, OperationErrorType>;
typedef OperationFailure<T> = CqrsMethodFailure<T, OperationErrorType>;

extension CommandFailureValidationErrorExtension on CommandFailure {
  bool get isInvalid => error.errorType == CommandErrorType.validation;
  List<ValidationError> get validationErrors => error.validationErrors;
}

/// Generic result for CQRS method result. Can be either [CqrsMethodSuccess]
/// or [QFailure].
sealed class CqrsMethodResult<T, E> extends Equatable {
  /// Creates a [CqrsMethodResult] class.
  const CqrsMethodResult();

  /// Whether this instance is of final type [CqrsMethodSuccess].
  bool get isSuccess => this is CqrsMethodSuccess<T, E>;

  /// Whether this instance is of final type [QFailure].
  bool get isFailure => this is CqrsMethodFailure<T, E>;
}

/// Generic class which represents a result of succesful query execution.
final class CqrsMethodSuccess<T, E> extends CqrsMethodResult<T, E> {
  /// Creates a [CqrsMethodSuccess] class.
  const CqrsMethodSuccess(this.data);

  /// Data of type [T] returned from query execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class CqrsMethodFailure<T, E> extends CqrsMethodResult<T, E> {
  /// Creates a [CqrsMethodFailure] class.
  const CqrsMethodFailure(this.error);

  /// Error which was the reason of query failure
  final E error;

  @override
  List<Object?> get props => [error];
}
