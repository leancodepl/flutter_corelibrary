import 'dart:io';

import 'package:cqrs/src/cqrs.dart';
import 'package:cqrs/src/cqrs_exception.dart';
import 'package:cqrs/src/transport_types.dart';
import 'package:cqrs/src/wrapper/cqrs_error.dart';
import 'package:cqrs/src/wrapper/cqrs_result.dart';
import 'package:logging/logging.dart';

/// CQRS wrapper providing a convenient way of handling errors.
///
/// Example:
///
/// ```dart
/// final apiUri = Uri.parse('https://flowers.garden/api/');
/// final logger = Logger('BudgetManager')
///
/// final cqrs = Cqrs(
///   loginClient,
///   apiUri,
/// );
///
/// final cqrsWrapper = CqrsWrapper(
///   cqrs: cqrs,
///   logger: logger,
/// );
///
/// // Fetching first page of the transactions with error handling
/// final result = await cqrsWrapper.noThrowGet(AllFlowers(page: 1));
///
/// if (result.isSuccesful) {
///   print(result.data);
/// } else if (result.isFailure) {
///   print(result.error);
/// }
///
/// // Adding a new transaction and
/// final result = await cqrsWrapper.noThrowRun(
///   AddFlower(
///     title: 'Orchid',
///     color: 'red'
///   ),
/// );
///
/// if (result.isSuccess) {
///   print('Transaction added succefully');
/// } else if (result.isInvalid) {
///   print('Invalid data passed');
/// } else if (result.isFailure) {
///   print('Something failed');
/// }
/// ```
class CqrsWrapper {
  /// Creates a [CqrsWrapper] class.
  ///
  /// [cqrs] is a [Cqrs] object used for communicating with the backend via
  /// queries and commands. Wrapper uses [logger] for printing status messages
  /// about sent queries and commands.
  ///
  /// Specific query and command errors can be handled via respectively
  /// [onQueryError] and [onCommandError] callbacks. Those can be used to
  /// define cartain actions that need to happen everytime when result error
  /// occurs after calling either [noThrowGet] or [noThrowRun].
  const CqrsWrapper({
    required Cqrs cqrs,
    Logger? logger,
    void Function(CqrsQueryError error)? onQueryError,
    void Function(CqrsCommandError error)? onCommandError,
  })  : _cqrs = cqrs,
        _logger = logger,
        _onQueryError = onQueryError,
        _onCommandError = onCommandError;

  final Cqrs _cqrs;
  final Logger? _logger;
  final void Function(CqrsQueryError error)? _onQueryError;
  final void Function(CqrsCommandError error)? _onCommandError;

  /// Send a query to the backend via [Cqrs.get] and return the result of the
  /// execution.
  ///
  /// In case of an error [_onQueryError] is called if it was provided in the
  /// contructor. Refer to [CqrsQueryError] enum for list of all errors that
  /// are handled by the [CqrsWrapper].
  Future<CqrsQueryResult<T, CqrsQueryError>> noThrowGet<T>(
    Query<T> query, {
    Map<String, String> headers = const {},
  }) async {
    final result = await _noThrowGet(query, headers: headers);
    final error = result.error;

    if (result.isFailure && error != null) {
      _onQueryError?.call(error);
    }

    return result;
  }

  /// Send a command to the backend via [Cqrs.get] and return the result of the
  /// execution.
  ///
  /// In case of an error [_onCommandError] is called if it was provided in the
  /// contructor. Refer to [CqrsCommandError] enum for list of all errors that
  /// are handled by the [CqrsWrapper].
  Future<CqrsCommandResult<CqrsCommandError>> noThrowRun(
    Command command, {
    Map<String, String> headers = const {},
  }) async {
    final result = await _noThrowRun(command, headers: headers);
    final error = result.error;

    if (result.isFailure && error != null) {
      _onCommandError?.call(error);
    }

    return result;
  }

  Future<CqrsQueryResult<T, CqrsQueryError>> _noThrowGet<T>(
    Query<T> query, {
    required Map<String, String> headers,
  }) async {
    try {
      final data = await _cqrs.get(query, headers: headers);
      _logger?.info('Query ${query.runtimeType} executed successfully.');

      return CqrsQuerySuccess(data);
    } on SocketException catch (e, s) {
      _logger?.severe(
        'Query ${query.runtimeType} failed with network error.',
        e,
        s,
      );

      return const CqrsQueryFailure(CqrsQueryError.network);
    } catch (e, s) {
      _logger?.severe('Query ${query.runtimeType} failed unexpectedly.', e, s);

      if (e is! CqrsException) {
        return const CqrsQueryFailure(CqrsQueryError.unknown);
      }

      return switch (e.response.statusCode) {
        401 => const CqrsQueryFailure(CqrsQueryError.authentication),
        403 => const CqrsQueryFailure(CqrsQueryError.forbiddenAccess),
        _ => const CqrsQueryFailure(CqrsQueryError.unknown),
      };
    }
  }

  Future<CqrsCommandResult<CqrsCommandError>> _noThrowRun(
    Command command, {
    required Map<String, String> headers,
  }) async {
    try {
      final result = await _cqrs.run(command, headers: headers);

      if (result.success) {
        _logger?.info('Command ${command.runtimeType} executed successfully.');

        return const CqrsCommandSuccess();
      } else {
        final buffer = StringBuffer();
        for (final error in result.errors) {
          buffer.write('${error.message} (${error.code}), ');
        }

        _logger?.warning(
          'Command ${command.runtimeType} failed.'
          ' ValidationErrors: [$buffer]',
        );

        if (result.hasError(422)) {
          return CqrsCommandFailure(
            CqrsCommandError.validation,
            validationErrors: result.errors,
          );
        } else {
          return const CqrsCommandFailure(CqrsCommandError.unknown);
        }
      }
    } on SocketException catch (e, s) {
      _logger?.severe(
        'Command ${command.runtimeType} failed with network error.',
        e,
        s,
      );

      return const CqrsCommandFailure(CqrsCommandError.forbiddenAccess);
    } catch (e, s) {
      _logger?.severe(
        'Command ${command.runtimeType} failed unexpectedly.',
        e,
        s,
      );

      if (e is! CqrsException) {
        return const CqrsCommandFailure(CqrsCommandError.unknown);
      }

      return switch (e.response.statusCode) {
        401 => const CqrsCommandFailure(CqrsCommandError.authentication),
        403 => const CqrsCommandFailure(CqrsCommandError.forbiddenAccess),
        _ => const CqrsCommandFailure(CqrsCommandError.unknown),
      };
    }
  }
}
