/// Error types that are recognized by Cqrs.
enum CqrsError {
  /// Represents generic unknown
  unknown,

  /// Represents a network/socket error
  network,

  /// Represents a HTTP 403 error
  forbiddenAccess,

  /// Represents a HTTP 401 error
  authentication,

  /// Represents a validation error
  validation,
}
