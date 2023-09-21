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

typedef QueryResult<T> = _Result<T, QueryErrorType>;
typedef QuerySuccess<T> = _Success<T, QueryErrorType>;
typedef QueryFailure<T> = _Failure<T, QueryErrorType>;

typedef CommandResult = _Result<void, CommandError>;
typedef CommandSuccess = _Success<void, CommandError>;
typedef CommandFailure = _Failure<void, CommandError>;

typedef OperationResult<T> = _Result<T, OperationErrorType>;
typedef OperationSuccess<T> = _Success<T, OperationErrorType>;
typedef OperationFailure<T> = _Failure<T, OperationErrorType>;

extension CommandFailureValidationErrorExtension on CommandFailure {
  bool get isInvalid => error.errorType == CommandErrorType.validation;
  List<ValidationError> get validationErrors => error.validationErrors;
}

/// Generic result for CQRS method result. Can be either [_Success]
/// or [QFailure].
sealed class _Result<T, E> extends Equatable {
  /// Creates a [_Result] class.
  const _Result();

  /// Whether this instance is of final type [_Success].
  bool get isSuccess => this is _Success<T, E>;

  /// Whether this instance is of final type [QFailure].
  bool get isFailure => this is _Failure<T, E>;
}

/// Generic class which represents a result of succesful query execution.
final class _Success<T, E> extends _Result<T, E> {
  /// Creates a [_Success] class.
  const _Success(this.data);

  /// Data of type [T] returned from query execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class _Failure<T, E> extends _Result<T, E> {
  /// Creates a [_Failure] class.
  const _Failure(this.error);

  /// Error which was the reason of query failure
  final E error;

  @override
  List<Object?> get props => [error];
}
