import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

typedef ClientGetter = Client Function();

class CQRS {
  CQRS(this._getClient, this._apiEndpoint, this._timeLimit, {this.headers});

  Client get _client => _getClient();
  ClientGetter _getClient;
  Uri _apiEndpoint;
  Duration _timeLimit;
  Map<String, String> headers;

  Future<TResult> get<TResult>(Query<TResult> query) async {
    final Response response = await _client
        .post(_apiEndpoint.resolve('query/' + query.getFullName()),
            headers:
                headers ?? <String, String>{'Content-Type': 'application/json'},
            body: json.encode(query.toJson()))
        .timeout(_timeLimit);

    if (response.statusCode == 200) {
      final dynamic decodedJson = json.decode(_getReponseBodyString(response));
      return decodedJson != null ? query.resultFactory(decodedJson) : null;
    }

    throw CQRSException(response.statusCode, response.reasonPhrase);
  }

  Future<CommandResult> run(Command command) async {
    final Response response = await _client
        .post(_apiEndpoint.resolve('command/' + command.getFullName()),
            headers:
                headers ?? <String, String>{'Content-Type': 'application/json'},
            body: json.encode(command.toJson()))
        .timeout(_timeLimit);

    if (response.statusCode == 200 || response.statusCode == 422) {
      final dynamic decodedJson = json.decode(_getReponseBodyString(response));
      return _commandResultFromDecodedJson(decodedJson);
    }

    throw CQRSException(response.statusCode, response.reasonPhrase);
  }

  CommandResult _commandResultFromDecodedJson(Map<String, dynamic> map) {
    final bool wasSuccessful = map['WasSuccessful'];

    final List<dynamic> list = map['ValidationErrors'];

    final List<ValidationError> validationErrors = list
        .map((dynamic error) =>
            ValidationError(error['ErrorCode'], error['ErrorMessage']))
        .toList();

    return CommandResult(wasSuccessful, validationErrors);
  }

  String _getReponseBodyString(Response response) =>
      Encoding.getByName('utf-8').decode(response.bodyBytes);
}

abstract class Query<TResult> implements CallToApi {
  TResult resultFactory(dynamic decodedJson);
}

abstract class Command implements CallToApi {}

abstract class CallToApi {
  Map<String, dynamic> toJson();

  String getFullName();
}

class CommandResult {
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
