// ignore_for_file: public_member_api_docs

import 'package:cqrs/src/command_result.dart';
import 'package:cqrs/src/cqrs.dart';
import 'package:equatable/equatable.dart';

sealed class CqrsQueryResult<T, E> extends Equatable {
  const CqrsQueryResult();

  CqrsQuerySuccess<T, E>? get asSuccess => switch (this) {
        final CqrsQuerySuccess<T, E> s => s,
        CqrsQueryFailure() => null,
      };

  CqrsQueryFailure<T, E>? get asFailure => switch (this) {
        CqrsQuerySuccess() => null,
        final CqrsQueryFailure<T, E> f => f,
      };

  bool get isSuccess => asSuccess != null;
  bool get isFailure => asFailure != null;

  T? get data => asSuccess?.data;
  E? get error => asFailure?.error;
}

final class CqrsQuerySuccess<T, E> extends CqrsQueryResult<T, E> {
  const CqrsQuerySuccess(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

final class CqrsQueryFailure<T, E> extends CqrsQueryResult<T, E> {
  const CqrsQueryFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}

/// Generic class used to contain a result of [Cqrs] operations.
sealed class CqrsCommandResult<E> extends Equatable {
  /// Creates a [CqrsCommandResult] class
  const CqrsCommandResult();

  CqrsCommandSuccess<E>? get asSuccess => switch (this) {
        final CqrsCommandSuccess<E> s => s,
        CqrsCommandFailure() => null,
      };

  CqrsCommandFailure<E>? get asFailure => switch (this) {
        CqrsCommandSuccess() => null,
        final CqrsCommandFailure<E> f => f,
      };

  bool get isSuccess => asSuccess != null;
  bool get isFailure => asFailure != null;

  // Return
  E? get error => asFailure?.error;

  List<ValidationError> get validationErrors;
}

final class CqrsCommandSuccess<E> extends CqrsCommandResult<E> {
  const CqrsCommandSuccess() : validationErrors = const [];

  @override
  final List<ValidationError> validationErrors;

  @override
  List<Object?> get props => [];
}

final class CqrsCommandFailure<E> extends CqrsCommandResult<E> {
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
