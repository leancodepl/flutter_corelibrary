// ignore_for_file: public_member_api_docs

import 'package:cqrs_wrapper/src/cqrs_error.dart';
import 'package:equatable/equatable.dart';

sealed class CqrsResult<T, E extends CqrsError> extends Equatable {
  const CqrsResult();

  CqrsSuccess<T, E>? get asSuccess => switch (this) {
        final CqrsSuccess<T, E> s => s,
        CqrsFailure() => null,
      };

  CqrsFailure<T, E>? get asFailure => switch (this) {
        CqrsSuccess() => null,
        final CqrsFailure<T, E> f => f,
      };

  bool get isSuccess => asSuccess != null;
  bool get isFailure => asFailure != null;
  bool get isInvalid => asFailure?.error.asValidationError != null;

  T? get data => asSuccess?.data;
  E? get error => asFailure?.error;
}

final class CqrsSuccess<T, E extends CqrsError> extends CqrsResult<T, E> {
  const CqrsSuccess(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

final class CqrsFailure<T, E extends CqrsError> extends CqrsResult<T, E> {
  const CqrsFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}
