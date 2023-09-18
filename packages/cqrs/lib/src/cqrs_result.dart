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

/// Extension adding [isInvalid] getter for validation error checking on
/// [CqrsCommandResult] with error type [CqrsError].
extension CqrsCommandResultValidationErrorExtension
    on CqrsCommandResult<CqrsError> {
  /// Whether is a [CqrsCommandFailure] with validation errors.
  bool get isInvalid => error == CqrsError.validation;
}

/// Generic result for CQRS query result. Can be either [CqrsQuerySuccess]
/// or [CqrsQueryFailure].
sealed class CqrsQueryResult<T, E> extends Equatable {
  /// Creates a [CqrsQueryResult] class.
  const CqrsQueryResult();

  /// Casts to [CqrsQuerySuccess] or `null`.
  CqrsQuerySuccess<T, E>? get asSuccess => switch (this) {
        final CqrsQuerySuccess<T, E> s => s,
        CqrsQueryFailure() => null,
      };

  /// Casts to [CqrsQueryFailure] or `null`.
  CqrsQueryFailure<T, E>? get asFailure => switch (this) {
        CqrsQuerySuccess() => null,
        final CqrsQueryFailure<T, E> f => f,
      };

  /// Whether this instance can be casted to [CqrsQuerySuccess].
  bool get isSuccess => asSuccess != null;

  /// Whether this instance can be casted to [CqrsQueryFailure].
  bool get isFailure => asFailure != null;

  /// Returns [data] of type [T] for [CqrsQuerySuccess] and `null`
  /// for [CqrsQueryFailure].
  T? get data => asSuccess?.data;

  /// Returns [error] of type [E] for [CqrsQueryFailure] and `null`
  /// for [CqrsQuerySuccess].
  E? get error => asFailure?.error;
}

/// Generic class which represents a result of succesful query execution.
final class CqrsQuerySuccess<T, E> extends CqrsQueryResult<T, E> {
  /// Creates a [CqrsQuerySuccess] class.
  const CqrsQuerySuccess(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class CqrsQueryFailure<T, E> extends CqrsQueryResult<T, E> {
  /// Creates a [CqrsQueryFailure] class.
  const CqrsQueryFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}

/// Generic result for CQRS command result. Can be either [CqrsCommandSuccess]
/// or [CqrsCommandFailure].
sealed class CqrsCommandResult<E> extends Equatable {
  /// Creates a [CqrsCommandResult] class.
  const CqrsCommandResult();

  /// Casts to [CqrsCommandSuccess] or `null`.
  CqrsCommandSuccess<E>? get asSuccess => switch (this) {
        final CqrsCommandSuccess<E> s => s,
        CqrsCommandFailure() => null,
      };

  /// Casts to [CqrsCommandFailure] or `null`.
  CqrsCommandFailure<E>? get asFailure => switch (this) {
        CqrsCommandSuccess() => null,
        final CqrsCommandFailure<E> f => f,
      };

  /// Whether this instance can be casted to [CqrsCommandSuccess].
  bool get isSuccess => asSuccess != null;

  /// Whether this instance can be casted to [CqrsCommandFailure].
  bool get isFailure => asFailure != null;

  /// Returns an [error] of type [E] for [CqrsCommandFailure] and `null`
  /// for [CqrsCommandSuccess].
  E? get error => asFailure?.error;

  /// Returns a list of [ValidationError] errors.
  List<ValidationError> get validationErrors;
}

/// Generic class which represents a result of succesful command execution.
final class CqrsCommandSuccess<E> extends CqrsCommandResult<E> {
  /// Creates a [CqrsCommandSuccess] class.
  const CqrsCommandSuccess();

  @override
  final List<ValidationError> validationErrors = const [];

  @override
  List<Object?> get props => [];
}

/// Generic class which represents a result of unsuccesful command execution.
final class CqrsCommandFailure<E> extends CqrsCommandResult<E> {
  /// Creates a [CqrsCommandFailure] class.
  const CqrsCommandFailure(
    this.error, {
    this.validationErrors = const [],
  });

  @override
  final E error;

  @override
  final List<ValidationError> validationErrors;

  @override
  List<Object?> get props => [error, validationErrors];
}

/// Generic result for CQRS operation result. Can be either [CqrsQuerySuccess]
/// or [CqrsQueryFailure].
sealed class CqrsOperationResult<T, E> extends Equatable {
  /// Creates a [CqrsOperationResult] class.
  const CqrsOperationResult();

  /// Casts to [CqrsOperationSuccess] or `null`.
  CqrsOperationSuccess<T, E>? get asSuccess => switch (this) {
        final CqrsOperationSuccess<T, E> s => s,
        CqrsOperationFailure() => null,
      };

  /// Casts to [CqrsOperationFailure] or `null`.
  CqrsOperationFailure<T, E>? get asFailure => switch (this) {
        CqrsOperationSuccess() => null,
        final CqrsOperationFailure<T, E> f => f,
      };

  /// Whether this instance can be casted to [CqrsOperationSuccess].
  bool get isSuccess => asSuccess != null;

  /// Whether this instance can be casted to [CqrsOperationFailure].
  bool get isFailure => asFailure != null;

  /// Returns [data] of type [T] for [CqrsOperationSuccess] and `null`
  /// for [CqrsOperationFailure].
  T? get data => asSuccess?.data;

  /// Returns [error] of type [E] for [CqrsOperationFailure] and `null`
  /// for [CqrsOperationSuccess].
  E? get error => asFailure?.error;
}

/// Generic class which represents a result of succesful query execution.
final class CqrsOperationSuccess<T, E> extends CqrsOperationResult<T, E> {
  /// Creates a [CqrsOperationSuccess] class.
  const CqrsOperationSuccess(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class CqrsOperationFailure<T, E> extends CqrsOperationResult<T, E> {
  /// Creates a [CqrsOperationFailure] class.
  const CqrsOperationFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}
