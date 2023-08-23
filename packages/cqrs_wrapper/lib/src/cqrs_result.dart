// ignore_for_file: public_member_api_docs

import 'package:cqrs/cqrs.dart';
import 'package:cqrs_wrapper/src/cqrs_error.dart';
import 'package:equatable/equatable.dart';

sealed class CqrsResult<T, E> extends Equatable {
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

  T? get data => asSuccess?.data;
  E? get error => asFailure?.error;
}

final class CqrsSuccess<T, E> extends CqrsResult<T, E> {
  const CqrsSuccess(this.data);

  @override
  final T data;

  @override
  List<Object?> get props => [data];
}

final class CqrsFailure<T, E> extends CqrsResult<T, E> {
  const CqrsFailure(this.error);

  @override
  final E error;

  @override
  List<Object?> get props => [error];
}

typedef CqrsQueryResult<T> = CqrsResult<T, CqrsQueryError>;

class CqrsCommandResult {
  const CqrsCommandResult.success()
      : isSuccess = true,
        error = null,
        validationErrors = const [];

  CqrsCommandResult.validationError(List<ValidationError> validationErrors)
      : isSuccess = false,
        error = CqrsCommandError.validation,
        validationErrors = List.unmodifiable(validationErrors);

  CqrsCommandResult.nonValidationError(this.error)
      : isSuccess = false,
        validationErrors = const [];

  final bool isSuccess;

  bool get isFailure => error != null;
  bool get isInvalid => error == CqrsCommandError.validation;

  final List<ValidationError> validationErrors;
  final CqrsCommandError? error;
}
