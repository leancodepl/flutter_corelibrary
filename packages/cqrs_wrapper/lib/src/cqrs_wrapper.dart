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

  void onError(CqrsError error) {}

  // TODO: Differentiate errors being returned
  Future<CqrsQueryResult<T, CqrsError>> noThrowGet<T>(Query<T> query) async {
    try {
      final data = await _cqrs.get(query);
      _logger.info('Query ${query.runtimeType} executed successfully.');
      return CqrsQuerySuccess(data);
    } on SocketException catch (e, s) {
      _logger.severe(
        'Query ${query.runtimeType} failed with network error.',
        e,
        s,
      );
      return const CqrsQueryFailure(CqrsNetworkError());
    } catch (e, s) {
      _logger.severe('Query ${query.runtimeType} failed unexpectedly.', e, s);
      return const CqrsQueryFailure(CqrsUnknownError());
    }
  }

  // TODO: Differentiate errors being returned
  Future<CqrsCommandResult<CqrsError>> noThrowRun(Command command) async {
    try {
      final result = await _cqrs.run(command);

      if (result.success) {
        _logger.info('Command ${command.runtimeType} executed successfully.');

        return const CqrsCommandSuccess();
      } else {
        final buffer = StringBuffer();
        for (final error in result.errors) {
          buffer.write('${error.message} (${error.code}), ');
        }

        _logger.warning(
          'Command ${command.runtimeType} failed.'
          ' ValidationErrors: [$buffer]',
        );

        return CqrsCommandFailure(CqrsValidationError(result.errors));
      }
    } on SocketException catch (e, s) {
      _logger.severe(
        'Command ${command.runtimeType} failed with network error.',
        e,
        s,
      );
      return const CqrsCommandFailure(CqrsNetworkError());
    } catch (e, s) {
      _logger.severe(
        'Command ${command.runtimeType} failed unexpectedly.',
        e,
        s,
      );
      return const CqrsCommandFailure(CqrsUnknownError());
    }
  }
}
