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

import 'command_result.dart';
import 'cqrs_error.dart';

/// Generic result for CQRS query result. Can be either [CqrsQuerySuccess]
/// or [CqrsQueryFailure].
sealed class CqrsQueryResult<T> extends Equatable {
  /// Creates a [CqrsQueryResult] class.
  const CqrsQueryResult();

  /// Whether this instance is of final type [CqrsQuerySuccess].
  bool get isSuccess => switch (this) {
        CqrsQuerySuccess<T>() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CqrsQueryFailure].
  bool get isFailure => switch (this) {
        CqrsQueryFailure<T>() => true,
        _ => false,
      };
}

/// Generic class which represents a result of succesful query execution.
final class CqrsQuerySuccess<T> extends CqrsQueryResult<T> {
  /// Creates a [CqrsQuerySuccess] class.
  const CqrsQuerySuccess(this.data);

  /// Data of type [T] returned from query execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class CqrsQueryFailure<T> extends CqrsQueryResult<T> {
  /// Creates a [CqrsQueryFailure] class.
  const CqrsQueryFailure(this.error);

  /// Error which was the reason of query failure
  final CqrsError error;

  @override
  List<Object?> get props => [error];
}

/// Generic result for CQRS command result. Can be either [CqrsCommandSuccess]
/// or [CqrsCommandFailure].
sealed class CqrsCommandResult extends Equatable {
  /// Creates a [CqrsCommandResult] class.
  const CqrsCommandResult();

  /// Whether this instance is of final type [CqrsCommandSuccess].
  bool get isSuccess => switch (this) {
        CqrsCommandSuccess() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CqrsCommandFailure].
  bool get isFailure => switch (this) {
        CqrsCommandFailure() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CqrsCommandFailure] and comes
  /// from validation error.
  bool get isInvalid => switch (this) {
        CqrsCommandFailure(error: CqrsError.validation) => true,
        _ => false,
      };

  /// Returns a list of [ValidationError] errors.
  List<ValidationError> get validationErrors => const [];
}

/// Generic class which represents a result of succesful command execution.
final class CqrsCommandSuccess extends CqrsCommandResult {
  /// Creates a [CqrsCommandSuccess] class.
  const CqrsCommandSuccess();

  @override
  List<Object?> get props => [true];
}

/// Generic class which represents a result of unsuccesful command execution.
final class CqrsCommandFailure extends CqrsCommandResult {
  /// Creates a [CqrsCommandFailure] class.
  const CqrsCommandFailure(
    this.error, {
    this.validationErrors = const [],
  });

  /// Error which was the reason of query failure
  final CqrsError error;

  @override
  final List<ValidationError> validationErrors;

  @override
  List<Object?> get props => [error, validationErrors];
}

/// Generic result for CQRS operation result. Can be either [CqrsOperationSuccess]
/// or [CqrsOperationFailure].
sealed class CqrsOperationResult<T> extends Equatable {
  /// Creates a [CqrsOperationResult] class.
  const CqrsOperationResult();

  /// Whether this instance is of final type [CqrsOperationSuccess].
  bool get isSuccess => switch (this) {
        CqrsOperationSuccess<T>() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CqrsOperationFailure].
  bool get isFailure => switch (this) {
        CqrsOperationFailure<T>() => true,
        _ => false,
      };
}

/// Generic class which represents a result of succesful operation execution.
final class CqrsOperationSuccess<T> extends CqrsOperationResult<T> {
  /// Creates a [CqrsOperationSuccess] class.
  const CqrsOperationSuccess(this.data);

  /// Data of type [T] returned from operation execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful operation execution.
final class CqrsOperationFailure<T> extends CqrsOperationResult<T> {
  /// Creates a [CqrsOperationFailure] class.
  const CqrsOperationFailure(this.error);

  /// Error which was the reason of operation failure
  final CqrsError error;

  @override
  List<Object?> get props => [error];
}
