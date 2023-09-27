// Copyright 2023 LeanCode Sp. z o.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'command_response.dart';
import 'cqrs_error.dart';
import 'cqrs_middleware.dart';
import 'cqrs_result.dart';
import 'transport_types.dart';
import 'validation_error.dart';

enum _ResultType {
  success,
  jsonError,
  networkError,
  authenticationError,
  authorizationError,
  validationError,
  unknownError;

  String get description => switch (this) {
        success => 'executed successfully',
        jsonError => 'failed while decoding response body JSON',
        networkError => 'failed with network error',
        authenticationError => 'failed with authentication error',
        authorizationError => 'failed with authorization error',
        validationError => 'failed with validation errors',
        unknownError => 'failed unexpectedly',
      };
}

/// Class used for communicating with the backend via queries and commands.
class Cqrs {
  /// Creates a [Cqrs] class.
  ///
  /// `_client` is an [http.Client] client to be used for sending requests. It
  /// should handle authentication and renewing the token when it is neccessary.
  ///
  /// If there are errors with requests being sent to the wrong URL, make sure
  /// you provided a correct `_apiUri`, that is with presense or lack of the
  /// trailing slash.
  ///
  /// The `timeout` defaults to 30 seconds. `headers` have lesser priority than
  /// those provided directly into [get] or [run] methods and will be overrided
  /// by those in case of some headers sharing the same key.
  ///
  /// Any result (be it success or failure) of CQRS method will be logged
  /// given the `logger` is provided.
  ///
  /// In case when a global result handling is needed, one might provide
  /// a `middlewares` list with a collection of [CqrsMiddleware] objects. Every
  /// time a result is returned, [Cqrs.get] and [Cqrs.run] will execute for
  /// each middleware on the list [CqrsMiddleware.handleQueryResult]
  /// and [CqrsMiddleware.handleCommandResult] accordingly.
  Cqrs(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> headers = const {},
    Logger? logger,
    List<CqrsMiddleware> middlewares = const [],
  })  : _timeout = timeout,
        _headers = headers,
        _logger = logger,
        _middlewares = [...middlewares];

  final http.Client _client;
  final Uri _apiUri;
  final Duration _timeout;
  final Map<String, String> _headers;
  final Logger? _logger;
  final List<CqrsMiddleware> _middlewares;

  /// Add given middleware at the end of a list.
  void addMiddleware(CqrsMiddleware middleware) {
    _middlewares.add(middleware);
  }

  /// Remove given middleware from the list.
  void removeMiddleware(CqrsMiddleware middleware) {
    _middlewares.remove(middleware);
  }

  /// Send a query to the backend and expect a result of the type `T`.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [Cqrs]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// After successful completion returns [QuerySuccess] with received data
  /// of type `T`. A [QueryFailure] will be returned with an according
  /// [QueryError] in case of an error.
  Future<QueryResult<T>> get<T>(
    Query<T> query, {
    Map<String, String> headers = const {},
  }) async {
    final result = await _get(query, headers: headers);

    return _middlewares.fold(
      result,
      (result, middleware) async => middleware.handleQueryResult(await result),
    );
  }

  /// Send a command to the backend and get the results of running it, that is
  /// whether it was successful and validation errors if there were any.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [Cqrs]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// After successful completion returns [CommandSuccess].
  /// A [CommandFailure] will be returned with an according [CommandError]
  /// in case of an error and with list of [ValidationError] errors (in case of
  /// validation error).
  Future<CommandResult> run(
    Command command, {
    Map<String, String> headers = const {},
  }) async {
    final result = await _run(command, headers: headers);

    return _middlewares.fold(
      result,
      (result, middleware) async =>
          middleware.handleCommandResult(await result),
    );
  }

  /// Send a operation to the backend and expect a result of the type `T`.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [Cqrs]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// After successful completion returns [OperationSuccess] with received
  /// data of type `T`. A [OperationFailure] will be returned with
  /// an according [OperationError] in case of an error.
  Future<OperationResult<T>> perform<T>(
    Operation<T> operation, {
    Map<String, String> headers = const {},
  }) async {
    final result = await _perform(operation, headers: headers);

    return _middlewares.fold(
      result,
      (result, middleware) async =>
          middleware.handleOperationResult(await result),
    );
  }

  Future<QueryResult<T>> _get<T>(
    Query<T> query, {
    required Map<String, String> headers,
  }) async {
    try {
      final response =
          await _send(query, pathPrefix: 'query', headers: headers);

      if (response.statusCode == 200) {
        try {
          final dynamic json = jsonDecode(response.body);
          final result = query.resultFactory(json);
          _log(query, _ResultType.success);
          return QuerySuccess(result);
        } catch (e, s) {
          _log(query, _ResultType.jsonError, e, s);
          return QueryFailure<T>(QueryError.unknown);
        }
      }

      if (response.statusCode == 401) {
        _log(query, _ResultType.authenticationError);
        return QueryFailure<T>(QueryError.authentication);
      }
      if (response.statusCode == 403) {
        _log(query, _ResultType.authorizationError);
        return QueryFailure<T>(QueryError.authorization);
      }
    } on SocketException catch (e, s) {
      _log(query, _ResultType.networkError, e, s);
      return QueryFailure<T>(QueryError.network);
    } catch (e, s) {
      _log(query, _ResultType.unknownError, e, s);
      return QueryFailure<T>(QueryError.unknown);
    }

    _log(query, _ResultType.unknownError);
    return QueryFailure<T>(QueryError.unknown);
  }

  Future<CommandResult> _run(
    Command command, {
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _send(
        command,
        pathPrefix: 'command',
        headers: headers,
      );

      if ([200, 422].contains(response.statusCode)) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final result = CommandResponse.fromJson(json);

          if (response.statusCode == 200) {
            _log(command, _ResultType.success);
            return const CommandSuccess();
          }

          _log(command, _ResultType.validationError, null, null, result.errors);
          return CommandFailure(
            CommandError.validation,
            validationErrors: result.errors,
          );
        } catch (e, s) {
          _log(command, _ResultType.jsonError, e, s);
          return const CommandFailure(CommandError.unknown);
        }
      }
      if (response.statusCode == 401) {
        _log(command, _ResultType.authenticationError);
        return const CommandFailure(CommandError.authentication);
      }
      if (response.statusCode == 403) {
        _log(command, _ResultType.authorizationError);
        return const CommandFailure(CommandError.authorization);
      }
    } on SocketException catch (e, s) {
      _log(command, _ResultType.networkError, e, s);
      return const CommandFailure(CommandError.network);
    } catch (e, s) {
      _log(command, _ResultType.unknownError, e, s);
      return const CommandFailure(CommandError.unknown);
    }

    _log(command, _ResultType.unknownError);
    return const CommandFailure(CommandError.unknown);
  }

  Future<OperationResult<T>> _perform<T>(
    Operation<T> operation, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final response =
          await _send(operation, pathPrefix: 'operation', headers: headers);

      if (response.statusCode == 200) {
        try {
          final dynamic json = jsonDecode(response.body);
          final result = operation.resultFactory(json);
          _log(operation, _ResultType.success);
          return OperationSuccess<T>(result);
        } catch (e, s) {
          _log(operation, _ResultType.jsonError, e, s);
          return OperationFailure<T>(OperationError.unknown);
        }
      }

      if (response.statusCode == 401) {
        _log(operation, _ResultType.authenticationError);
        return OperationFailure<T>(OperationError.authentication);
      }
      if (response.statusCode == 403) {
        _log(operation, _ResultType.authorizationError);
        return OperationFailure<T>(OperationError.authorization);
      }
    } on SocketException catch (e, s) {
      _log(operation, _ResultType.networkError, e, s);
      return OperationFailure<T>(OperationError.network);
    } catch (e, s) {
      _log(operation, _ResultType.unknownError, e, s);
      return OperationFailure<T>(OperationError.unknown);
    }

    _log(operation, _ResultType.unknownError);
    return OperationFailure<T>(OperationError.unknown);
  }

  Future<http.Response> _send(
    CqrsMethod cqrsMethod, {
    required String pathPrefix,
    Map<String, String> headers = const {},
  }) async {
    return _client.post(
      _apiUri.resolve('$pathPrefix/${cqrsMethod.getFullName()}'),
      body: jsonEncode(cqrsMethod),
      headers: {
        ..._headers,
        ...headers,
        'Content-Type': 'application/json',
      },
    ).timeout(_timeout);
  }

  void _log(
    CqrsMethod method,
    _ResultType result, [
    Object? error,
    StackTrace? stackTrace,
    List<ValidationError> validationErrors = const [],
  ]) {
    final logger = _logger;
    if (logger == null) {
      return;
    }

    final log = switch (result) {
      _ResultType.success => logger.info,
      _ResultType.validationError => logger.warning,
      _ResultType.jsonError ||
      _ResultType.networkError ||
      _ResultType.authenticationError ||
      _ResultType.authorizationError ||
      _ResultType.unknownError =>
        logger.severe,
    };

    final methodTypePrefix = switch (method) {
      Query() => 'Query',
      Command() => 'Command',
      Operation() => 'Operation',
    };

    final validationErrorsBuffer = StringBuffer();
    for (final error in validationErrors) {
      validationErrorsBuffer.write('${error.message} (${error.code}), ');
    }

    final details = switch (result) {
      _ResultType.validationError =>
        '$methodTypePrefix ${method.runtimeType} ${result.description}:\n'
            '$validationErrorsBuffer',
      _ => '$methodTypePrefix ${method.runtimeType} ${result.description}.',
    };

    log.call(details, error, stackTrace);
  }
}
