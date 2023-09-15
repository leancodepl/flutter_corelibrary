/// Error types that are recognized by Cqrs.
enum CqrsError {
  /// Represents a network/socket error
  network,

  /// Represents a HTTP 403 forbidden access error
  forbiddenAccess,

  /// Represents a HTTP 401 authetication error
  authentication,

  /// Represents a HTTP 422 validation error
  validation,

  /// Represents a generic error which covers all remaining errors
  unknown,
}
