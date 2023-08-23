// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:cqrs/cqrs.dart';
import 'package:cqrs_wrapper/src/cqrs_error.dart';
import 'package:cqrs_wrapper/src/cqrs_result.dart';
import 'package:logging/logging.dart';

class CqrsWrapper {
  const CqrsWrapper({
    required Cqrs cqrs,
    required Logger logger,
    void Function(CqrsQueryError error)? onQueryError,
    void Function(CqrsCommandError error)? onCommandError,
  })  : _cqrs = cqrs,
        _logger = logger,
        _onQueryError = onQueryError,
        _onCommandError = onCommandError;

  final Cqrs _cqrs;
  final Logger _logger;

  final void Function(CqrsQueryError error)? _onQueryError;
  final void Function(CqrsCommandError error)? _onCommandError;

  Future<CqrsQueryResult<T>> noThrowGet<T>(Query<T> query) async {
    final result = await _noThrowGet(query);
    final error = result.error;

    if (result.isFailure && error != null) {
      _onQueryError?.call(error);
    }

    return result;
  }

  Future<CqrsCommandResult> noThrowRun(Command command) async {
    final result = await _noThrowRun(command);
    final error = result.error;

    if (result.isFailure && error != null) {
      _onCommandError?.call(error);
    }

    return result;
  }

  Future<CqrsQueryResult<T>> _noThrowGet<T>(Query<T> query) async {
    try {
      final data = await _cqrs.get(query);
      _logger.info('Query ${query.runtimeType} executed successfully.');

      return CqrsSuccess(data);
    } on SocketException catch (e, s) {
      _logger.severe(
        'Query ${query.runtimeType} failed with network error.',
        e,
        s,
      );

      return const CqrsFailure(CqrsQueryError.network);
    } catch (e, s) {
      _logger.severe('Query ${query.runtimeType} failed unexpectedly.', e, s);

      if (e is! CqrsException) {
        return const CqrsFailure(CqrsQueryError.unknown);
      }

      return switch (e.response.statusCode) {
        401 => const CqrsFailure(CqrsQueryError.authentication),
        403 => const CqrsFailure(CqrsQueryError.forbiddenAccess),
        _ => const CqrsFailure(CqrsQueryError.unknown),
      };
    }
  }

  Future<CqrsCommandResult> _noThrowRun(Command command) async {
    try {
      final result = await _cqrs.run(command);

      if (result.success) {
        _logger.info('Command ${command.runtimeType} executed successfully.');

        return const CqrsCommandResult.success();
      } else {
        final buffer = StringBuffer();
        for (final error in result.errors) {
          buffer.write('${error.message} (${error.code}), ');
        }

        _logger.warning(
          'Command ${command.runtimeType} failed.'
          ' ValidationErrors: [$buffer]',
        );

        if (result.hasError(422)) {
          return CqrsCommandResult.validationError(result.errors);
        } else {
          return CqrsCommandResult.nonValidationError(
            CqrsCommandError.unknown,
          );
        }
      }
    } on SocketException catch (e, s) {
      _logger.severe(
        'Command ${command.runtimeType} failed with network error.',
        e,
        s,
      );

      return CqrsCommandResult.nonValidationError(
        CqrsCommandError.forbiddenAccess,
      );
    } catch (e, s) {
      _logger.severe(
        'Command ${command.runtimeType} failed unexpectedly.',
        e,
        s,
      );

      if (e is! CqrsException) {
        return CqrsCommandResult.nonValidationError(
          CqrsCommandError.unknown,
        );
      }

      return switch (e.response.statusCode) {
        401 => CqrsCommandResult.nonValidationError(
            CqrsCommandError.authentication,
          ),
        403 => CqrsCommandResult.nonValidationError(
            CqrsCommandError.forbiddenAccess,
          ),
        _ => CqrsCommandResult.nonValidationError(
            CqrsCommandError.unknown,
          ),
      };
    }
  }
}
