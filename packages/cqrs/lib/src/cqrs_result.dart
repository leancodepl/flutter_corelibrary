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

/// Represents a result of query execution.
typedef QueryResult<T> = CqrsMethodResult<T, QueryErrorType>;

/// Represents a result of successful query execution.
typedef QuerySuccess<T> = CqrsMethodSuccess<T, QueryErrorType>;

/// Represents a result of unsuccessful query execution.
typedef QueryFailure<T> = CqrsMethodFailure<T, QueryErrorType>;

/// Represents a result of command execution.
typedef CommandResult = CqrsMethodResult<void, CommandErrorType>;

/// Represents a result of successful command execution.
typedef CommandSuccess = CqrsMethodSuccess<void, CommandErrorType>;

/// Represents a result of unsuccessful command execution.
class CommandFailure extends CqrsMethodFailure<void, CommandErrorType> {
  /// Creates [CommandFailure] class.
  const CommandFailure(
    super.error, {
    this.validationErrors = const [],
  });

  /// List of validation errors returned from backend.
  final List<ValidationError> validationErrors;
}

/// Extension on [CommandResult] which allows to check whether failure
/// of command was caused by a validation error.
extension CommandFailureValidationErrorExtension on CommandResult {
  /// Whether this instance is of type [CqrsMethodFailure] with
  /// [CommandErrorType.validation].
  bool get isInvalid => switch (this) {
        CommandFailure(error: CommandErrorType.validation) => true,
        _ => false
      };
}

/// Represents a result of operation execution.
typedef OperationResult<T> = CqrsMethodResult<T, OperationErrorType>;

/// Represents a result of successful operation execution.
typedef OperationSuccess<T> = CqrsMethodSuccess<T, OperationErrorType>;

/// Represents a result of unsuccessful operation execution.
typedef OperationFailure<T> = CqrsMethodFailure<T, OperationErrorType>;

/// Generic result for CQRS method result. Can be either [CqrsMethodSuccess]
/// or [CqrsMethodFailure].
sealed class CqrsMethodResult<T, E> extends Equatable {
  /// Creates a [CqrsMethodResult] class.
  const CqrsMethodResult();

  /// Whether this instance is of type [CqrsMethodSuccess].
  bool get isSuccess => this is CqrsMethodSuccess<T, E>;

  /// Whether this instance is of type [CqrsMethodFailure].
  bool get isFailure => this is CqrsMethodFailure<T, E>;
}

/// Generic class which represents a result of succesful query execution.
class CqrsMethodSuccess<T, E> extends CqrsMethodResult<T, E> {
  /// Creates a [CqrsMethodSuccess] class.
  const CqrsMethodSuccess(this.data);

  /// Data of type [T] returned from query execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
class CqrsMethodFailure<T, E> extends CqrsMethodResult<T, E> {
  /// Creates a [CqrsMethodFailure] class.
  const CqrsMethodFailure(this.error);

  /// Error which was the reason of query failure
  final E error;

  @override
  List<Object?> get props => [error];
}
