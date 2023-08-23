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
  })  : _cqrs = cqrs,
        _logger = logger;

  final Cqrs _cqrs;
  final Logger _logger;

  // void onQueryError(CqrsQueryError error) {}

  Future<CqrsQueryResult<T>> noThrowGet<T>(Query<T> query) async {
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

  Future<CqrsCommandResult> noThrowRun(Command command) async {
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

        if (result.hasError(401)) {
          return CqrsCommandResult.nonValidationError(
            CqrsCommandError.authentication,
          );
        } else if (result.hasError(403)) {
          return CqrsCommandResult.nonValidationError(
            CqrsCommandError.forbiddenAccess,
          );
        } else if (result.hasError(422)) {
          return CqrsCommandResult.validationError(result.errors);
        } else {
          return CqrsCommandResult.nonValidationError(CqrsCommandError.unknown);
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
      return CqrsCommandResult.nonValidationError(CqrsCommandError.unknown);
    }
  }
}
