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

/// Generic result for CQRS query result. Can be either [QSuccess]
/// or [QFailure].
sealed class QResult<T> extends Equatable {
  /// Creates a [QResult] class.
  const QResult();

  /// Whether this instance is of final type [QSuccess].
  bool get isSuccess => switch (this) {
        QSuccess<T>() => true,
        _ => false,
      };

  /// Whether this instance is of final type [QFailure].
  bool get isFailure => switch (this) {
        QFailure<T>() => true,
        _ => false,
      };
}

/// Generic class which represents a result of succesful query execution.
final class QSuccess<T> extends QResult<T> {
  /// Creates a [QSuccess] class.
  const QSuccess(this.data);

  /// Data of type [T] returned from query execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful query execution.
final class QFailure<T> extends QResult<T> {
  /// Creates a [QFailure] class.
  const QFailure(this.error);

  /// Error which was the reason of query failure
  final CqrsError error;

  @override
  List<Object?> get props => [error];
}

/// Generic result for CQRS command result. Can be either [CSuccess]
/// or [CFailure].
sealed class CResult extends Equatable {
  /// Creates a [CResult] class.
  const CResult();

  /// Whether this instance is of final type [CSuccess].
  bool get isSuccess => switch (this) {
        CSuccess() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CFailure].
  bool get isFailure => switch (this) {
        CFailure() => true,
        _ => false,
      };

  /// Whether this instance is of final type [CFailure] and comes
  /// from validation error.
  bool get isInvalid => switch (this) {
        CFailure(error: CqrsError.validation) => true,
        _ => false,
      };

  /// Returns a list of [ValidationError] errors.
  List<ValidationError> get validationErrors => const [];
}

/// Generic class which represents a result of succesful command execution.
final class CSuccess extends CResult {
  /// Creates a [CSuccess] class.
  const CSuccess();

  @override
  List<Object?> get props => [true];
}

/// Generic class which represents a result of unsuccesful command execution.
final class CFailure extends CResult {
  /// Creates a [CFailure] class.
  const CFailure(
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

/// Generic result for CQRS operation result. Can be either [OSuccess]
/// or [OFailure].
sealed class OResult<T> extends Equatable {
  /// Creates a [OResult] class.
  const OResult();

  /// Whether this instance is of final type [OSuccess].
  bool get isSuccess => switch (this) {
        OSuccess<T>() => true,
        _ => false,
      };

  /// Whether this instance is of final type [OFailure].
  bool get isFailure => switch (this) {
        OFailure<T>() => true,
        _ => false,
      };
}

/// Generic class which represents a result of succesful operation execution.
final class OSuccess<T> extends OResult<T> {
  /// Creates a [OSuccess] class.
  const OSuccess(this.data);

  /// Data of type [T] returned from operation execution.
  final T data;

  @override
  List<Object?> get props => [data];
}

/// Generic class which represents a result of unsuccesful operation execution.
final class OFailure<T> extends OResult<T> {
  /// Creates a [OFailure] class.
  const OFailure(this.error);

  /// Error which was the reason of operation failure
  final CqrsError error;

  @override
  List<Object?> get props => [error];
}
