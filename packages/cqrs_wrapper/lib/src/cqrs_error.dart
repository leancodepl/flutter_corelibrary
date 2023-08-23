// ignore_for_file: public_member_api_docs

import 'package:cqrs/cqrs.dart';

sealed class CqrsError {
  const CqrsError();

  CqrsValidationError? get asValidationError => switch (this) {
        final CqrsValidationError v => v,
        _ => null,
      };

  List<ValidationError> get validationErrors => switch (this) {
        CqrsValidationError(:final validationErrors) => validationErrors,
        _ => const [],
      };

  bool get isValidationError => asValidationError != null;
}

final class CqrsValidationError extends CqrsError {
  CqrsValidationError(List<ValidationError> validationErrors)
      : validationErrors = List.unmodifiable(validationErrors);

  @override
  final List<ValidationError> validationErrors;
}

final class CqrsUnknownError extends CqrsError {
  const CqrsUnknownError();
}

final class CqrsNetworkError extends CqrsError {
  const CqrsNetworkError();
}

final class CqrsAuthorizationError extends CqrsError {
  const CqrsAuthorizationError();
}

final class CqrsAuthenticationError extends CqrsError {
  const CqrsAuthenticationError();
}
