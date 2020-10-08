import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import 'transport_types.dart';

typedef ClientFactory = Client Function();

class CQRS {
  CQRS(
    this._clientFactory,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> headers = const {},
  })  : _timeout = timeout,
        _headers = headers;

  final ClientFactory _clientFactory;
  final Uri _apiUri;
  final Duration _timeout;
  final Map<String, String> _headers;

  Client get _client => _clientFactory();

  Future<T> get<T>(
    Query<T> query, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _send(query, headers: headers);

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return decodedJson != null ? query.resultFactory(decodedJson) : null;
    }

    throw CQRSException(response.statusCode, response.reasonPhrase);
  }

  Future<CommandResult> run(
    Command command, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _send(command, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 422) {
      final decodedJson = json.decode(response.body) as Map<String, dynamic>;
      return _commandResultFromDecodedJson(decodedJson);
    }

    throw CQRSException(response.statusCode, response.reasonPhrase);
  }

  Future<Response> _send(
    Contractable contractable, {
    Map<String, String> headers = const {},
  }) async {
    return _client.post(
      _apiUri
          .resolve('${contractable.pathPrefix}/${contractable.getFullName()}'),
      body: json.encode(contractable),
      headers: {
        ..._headers,
        ...headers,
        'Content-Type': 'application/json',
      },
    ).timeout(_timeout);
  }

  CommandResult _commandResultFromDecodedJson(Map<String, dynamic> map) {
    final wasSuccessful = map['WasSuccessful'] as bool;

    final list = map['ValidationErrors'] as List;

    final validationErrors = list
        .map((error) => ValidationError(
              error['ErrorCode'] as int,
              error['ErrorMessage'] as String,
            ))
        .toList();

    return CommandResult(wasSuccessful, validationErrors);
  }
}

class CommandResult {
  // ignore: avoid_positional_boolean_parameters
  const CommandResult(this.wasSuccessful, this.validationErrors);

  final bool wasSuccessful;
  final List<ValidationError> validationErrors;
}

class ValidationError {
  const ValidationError(this.code, this.message);

  final int code;
  final String message;
}

class CQRSException implements Exception {
  const CQRSException(this.statusCode, this.reasonPhrase);

  final int statusCode;
  final String reasonPhrase;

  @override
  String toString() {
    return '$statusCode: $reasonPhrase';
  }
}
