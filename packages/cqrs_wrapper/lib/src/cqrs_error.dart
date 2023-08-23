// ignore_for_file: public_member_api_docs

import 'package:cqrs/cqrs.dart';

abstract class CqrsError {}

class CqrsValidationError implements CqrsError {
  CqrsValidationError(List<ValidationError> validationErrors)
      : validationErrors = List.unmodifiable(validationErrors);

  final List<ValidationError> validationErrors;
}

class CqrsUnknownError implements CqrsError {
  const CqrsUnknownError();
}

class CqrsNetworkError implements CqrsError {
  const CqrsNetworkError();
}

class CqrsAuthorizationError implements CqrsError {
  const CqrsAuthorizationError();
}

class CqrsAuthenticationError implements CqrsError {
  const CqrsAuthenticationError();
}
