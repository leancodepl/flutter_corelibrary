import 'package:oauth2/oauth2.dart';

abstract class LoginResult {
  const LoginResult();
}

abstract class RefreshResult {
  const RefreshResult();
}

class UnexpectedOAuthError implements RefreshResult, LoginResult {
  const UnexpectedOAuthError();
}

class Success implements RefreshResult, LoginResult {
  const Success();
}

class CannotBeRefreshed implements RefreshResult {
  const CannotBeRefreshed();
}

class AuthorizationFailed implements RefreshResult, LoginResult {
  AuthorizationFailed.fromException(AuthorizationException exception)
      : error = _parseError(exception.error),
        description = exception.description,
        uri = exception.uri;

  final ErrorType error;
  final String description;
  final Uri uri;

  static ErrorType _parseError(String error) {
    switch (error) {
      case 'invalid_request':
        return ErrorType.invalidRequest;
      case 'invalid_client':
        return ErrorType.invalidClient;
      case 'invalid_grant':
        return ErrorType.invalidGrant;
      case 'unauthorized_client':
        return ErrorType.unauthorizedClient;
      case 'unsupported_grant_type':
        return ErrorType.unsupportedGrantType;
      case 'invalid_scope':
        return ErrorType.invalidScope;
      default:
        return ErrorType.undefined;
    }
  }
}

enum ErrorType {
  undefined,
  invalidRequest,
  invalidClient,
  invalidGrant,
  unauthorizedClient,
  unsupportedGrantType,
  invalidScope,
}
