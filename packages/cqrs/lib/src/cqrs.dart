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

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cqrs/src/command_result.dart';
import 'package:cqrs/src/cqrs_error.dart';
import 'package:cqrs/src/cqrs_result.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'cqrs_exception.dart';
import 'transport_types.dart';

enum _ResultType {
  success,
  jsonError,
  networkError,
  authenticationError,
  forbiddenAccessError,
  validationError,
  unknownError;

  String get description => switch (this) {
        success => 'executed successfully',
        jsonError => 'failed while decoding response body JSON',
        networkError => 'failed with network error',
        authenticationError => 'failed with authentication',
        forbiddenAccessError => 'failed with forbidden access error',
        validationError => 'failed with following validation errors',
        unknownError => 'failed unexpectedly',
      };
}

class Cqrs {
  Cqrs(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> headers = const {},
    Logger? logger,
  })  : _timeout = timeout,
        _headers = headers,
        _logger = logger;

  final http.Client _client;
  final Uri _apiUri;
  final Duration _timeout;
  final Map<String, String> _headers;
  final Logger? _logger;

  Future<CqrsQueryResult<T, CqrsError>> get<T>(
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
          return CqrsQuerySuccess(result);
        } catch (e, s) {
          _log(query, _ResultType.jsonError, e, s);
          return const CqrsQueryFailure(CqrsError.unknown);
        }
      }

      if (response.statusCode == 401) {
        _log(query, _ResultType.authenticationError);
        return const CqrsQueryFailure(CqrsError.authentication);
      }
      if (response.statusCode == 403) {
        _log(query, _ResultType.forbiddenAccessError);
        return const CqrsQueryFailure(CqrsError.forbiddenAccess);
      }
    } catch (e, s) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        _log(query, _ResultType.networkError, e, s);
        return const CqrsQueryFailure(CqrsError.network);
      }
      _log(query, _ResultType.unknownError, e, s);
      return const CqrsQueryFailure(CqrsError.unknown);
    }

    _log(query, _ResultType.unknownError);
    return const CqrsQueryFailure(CqrsError.unknown);
  }

  /// Send a command to the backend and get the results of running it, that is
  /// whether it was successful and validation errors if there were any.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [Cqrs]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// A [CqrsException] will be thrown in case of an error.
  Future<CqrsCommandResult<CqrsError>> run(
    Command command, {
    Map<String, String> headers = const {},
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
          final result = CommandResult.fromJson(json);

          if (response.statusCode == 200) {
            _log(command, _ResultType.success);
            return const CqrsCommandSuccess();
          }

          _log(command, _ResultType.validationError, null, null, result.errors);
          return CqrsCommandFailure(
            CqrsError.validation,
            validationErrors: result.errors,
          );
        } catch (e, s) {
          _log(command, _ResultType.jsonError, e, s);
          return const CqrsCommandFailure(CqrsError.unknown);
        }
      }
    } catch (e, s) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        _log(command, _ResultType.networkError, e, s);
        return const CqrsCommandFailure(CqrsError.network);
      }
      _log(command, _ResultType.unknownError, e, s);
      return const CqrsCommandFailure(CqrsError.unknown);
    }

    _log(command, _ResultType.unknownError);
    return const CqrsCommandFailure(CqrsError.unknown);
  }

  Future<T> perform<T>(
    Operation<T> operation, {
    Map<String, String> headers = const {},
  }) async {
    final response =
        await _send(operation, pathPrefix: 'operation', headers: headers);

    if (response.statusCode == 200) {
      try {
        final dynamic json = jsonDecode(response.body);
        final result = operation.resultFactory(json);
        _log(operation, _ResultType.success);
        return result;
      } catch (e, s) {
        _log(operation, _ResultType.jsonError, e, s);
      }
    }

    _log(operation, _ResultType.unknownError);

    throw CqrsException(
      response,
      'Invalid, non 200 status code returned by ${operation.getFullName()} operation.',
    );
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
    final log = switch (result) {
      _ResultType.success => _logger?.info,
      _ResultType.validationError => _logger?.warning,
      _ => _logger?.severe,
    };

    final methodTypePrefix = switch (method) {
      Query() => 'Query',
      Command() => 'Command',
      _ => 'Operation',
    };

    final validationErrorsBuffer = StringBuffer();
    for (final error in validationErrors) {
      validationErrorsBuffer.write('${error.message} (${error.code}), ');
    }

    final details = switch (result) {
      _ResultType.validationError =>
        '$methodTypePrefix ${method.runtimeType} ${result.description}.\n'
            '$validationErrorsBuffer',
      _ => '$methodTypePrefix ${method.runtimeType} ${result.description}.',
    };

    log?.call(details, error, stackTrace);
  }
}
