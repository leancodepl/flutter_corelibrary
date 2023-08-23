// ignore_for_file: public_member_api_docs

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

sealed class CqrsCommandResult<E> extends Equatable {
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

  E? get error => asFailure?.error;
}

final class CqrsCommandSuccess<E> extends CqrsCommandResult<E> {
  const CqrsCommandSuccess();

  @override
  List<Object?> get props => [];
}

final class CqrsCommandFailure<E> extends CqrsCommandResult<E> {
  const CqrsCommandFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}
