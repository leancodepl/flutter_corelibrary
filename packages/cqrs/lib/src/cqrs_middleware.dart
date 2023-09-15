import 'package:cqrs/src/cqrs_error.dart';
import 'package:cqrs/src/cqrs_result.dart';

/// Abstract class for CQRS result handlers. Can be used to specify certain
/// behaviors that will be triggered for given errors i.e. showing snackbar
/// on network error or logging out on authetication error etc.
abstract class CqrsMiddleware {
  /// Creates [CqrsMiddleware] class.
  const CqrsMiddleware();

  /// Handle and return query result. If no modification of query result
  /// is needed then return the same `result` that is passed to the method.
  Future<CqrsQueryResult<T, CqrsError>> handleQueryResult<T>(
    CqrsQueryResult<T, CqrsError> result,
  );

  /// Handle and return command result. If no modification of command result
  /// is needed then return the same `result` that is passed to the method.
  Future<CqrsCommandResult<CqrsError>> handleCommandResult(
    CqrsCommandResult<CqrsError> result,
  );
}
