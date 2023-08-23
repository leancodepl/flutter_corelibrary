// ignore_for_file: public_member_api_docs

import 'package:cqrs/cqrs.dart';

enum CqrsCommandErrorType {
  validation,
  unknown,
  network,
  forbiddenAccess,
  authentication,
}

enum CqrsQueryErrorType {
  unknown,
  network,
  forbiddenAccess,
  authentication,
}

final class CqrsCommandError {
  CqrsCommandError.validation(List<ValidationError> validationErrors)
      : errorType = CqrsCommandErrorType.validation,
        validationErrors = List.unmodifiable(validationErrors);

  CqrsCommandError.unknown()
      : errorType = CqrsCommandErrorType.unknown,
        validationErrors = const [];

  CqrsCommandError.network()
      : errorType = CqrsCommandErrorType.network,
        validationErrors = const [];

  CqrsCommandError.forbiddenAccess()
      : errorType = CqrsCommandErrorType.forbiddenAccess,
        validationErrors = const [];

  CqrsCommandError.authentication()
      : errorType = CqrsCommandErrorType.authentication,
        validationErrors = const [];

  final List<ValidationError> validationErrors;
  final CqrsCommandErrorType errorType;

  bool get isValidationError => errorType == CqrsCommandErrorType.validation;
}

final class CqrsQueryError {
  const CqrsQueryError(this.errorType);

  final CqrsQueryErrorType errorType;
}
