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

import 'cqrs_error.dart';
import 'validation_error.dart';

/// Generic result for CQRS query result. Can be either [QuerySuccess]
/// or [QueryFailure].
sealed class QueryResult<T> extends Equatable {
  /// Creates a [QueryResult] class.
  const QueryResult();

  /// Whether this instance is of final type [QuerySuccess].
  bool get isSuccess => this is QuerySuccess<T>;

  /// Whether this instance is of final type [QueryFailure].
  bool get isFailure => this is QueryFailure<T>;
}

/// Generic class which represents a result of succesful query execution.
final class QuerySuccess<T> extends QueryResult<T> {
  /// Creates a [QuerySuccess] class.
  const QuerySuccess(this.data, {this.rawBody});

  /// Data of type [T] returned from query execution.
  final T data;

  /// Raw body received in query response.
  final String? rawBody;

  @override
  List<Object?> get props => [data, rawBody];
}

/// Generic class which represents a result of unsuccesful query execution.
final class QueryFailure<T> extends QueryResult<T> {
  /// Creates a [QueryFailure] class.
  const QueryFailure(this.error);

  /// Error which was the reason of query failure
  final QueryError error;

  @override
  List<Object?> get props => [error];
}

/// Result class for CQRS command result. Can be either [CommandSuccess]
/// or [CommandFailure].
sealed class CommandResult extends Equatable {
  /// Creates a [CommandResult] class.
  const CommandResult();

  /// Whether this instance is of final type [CommandSuccess].
  bool get isSuccess => this is CommandSuccess;

  /// Whether this instance is of final type [CommandFailure].
  bool get isFailure => this is CommandFailure;

  /// Whether this instance is of final type [CommandFailure] and comes
  /// from validation error.
  bool get isInvalid => switch (this) {
        CommandFailure(error: CommandError.validation) => true,
        _ => false,
      };
}

/// Class which represents a result of succesful command execution.
final class CommandSuccess extends CommandResult {
  /// Creates a [CommandSuccess] class.
  const CommandSuccess();

  @override
  List<Object?> get props => [];
}

/// Class which represents a result of unsuccesful command execution.
final class CommandFailure extends CommandResult {
  /// Creates a [CommandFailure] class.
  const CommandFailure(
    this.error, {
    this.validationErrors = const [],
  });

  /// Error which was the reason of query failure
  final CommandError error;

  /// A list of [ValidationError] errors returned from the backed after
  /// command execution.
  final List<ValidationError> validationErrors;

  /// Checks whether this [CommandFailure] contains a provided error `code` in
  /// its validation errors.
  bool hasError(int code) =>
      validationErrors.any((error) => error.code == code);

  /// Checks whether this [CommandFailure] contains a provided error `code` in
  /// its validation errors related to the `propertyName`.
  bool hasErrorForProperty(int code, String propertyName) => validationErrors
      .any((error) => error.code == code && error.propertyName == propertyName);

  @override
  List<Object?> get props => [error, validationErrors];
}

/// Generic result for CQRS operation result. Can be either [OperationSuccess]
/// or [OperationFailure].
sealed class OperationResult<T> extends Equatable {
  /// Creates a [OperationResult] class.
  const OperationResult();

  /// Whether this instance is of final type [OperationSuccess].
  bool get isSuccess => this is OperationSuccess<T>;

  /// Whether this instance is of final type [OperationFailure].
  bool get isFailure => this is OperationFailure<T>;
}

/// Generic class which represents a result of succesful operation execution.
final class OperationSuccess<T> extends OperationResult<T> {
  /// Creates a [OperationSuccess] class.
  const OperationSuccess(this.data);

  /// Data of type [T] returned from operation execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful operation execution.
final class OperationFailure<T> extends OperationResult<T> {
  /// Creates a [OperationFailure] class.
  const OperationFailure(this.error);

  /// Error which was the reason of operation failure
  final OperationError error;

  @override
  List<Object?> get props => [error];
}
