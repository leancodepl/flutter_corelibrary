// Copyright 2020 LeanCode Sp. z o.o.
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

import 'package:http/http.dart' as http;

import 'command_result.dart';
import 'cqrs_exception.dart';
import 'transport_types.dart';

/// Class used for communicating with the backend via queries and commands.
class CQRS {
  /// Creates a [CQRS] class.
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
  CQRS(
    this._client,
    this._apiUri, {
    Duration timeout = const Duration(seconds: 30),
    Map<String, String> headers = const {},
  })  : _timeout = timeout,
        _headers = headers;

  final http.Client _client;
  final Uri _apiUri;
  final Duration _timeout;
  final Map<String, String> _headers;

  /// Send a query to the backend and expect a result of the type `T`.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [CQRS]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// A [CQRSException] will be thrown in case of an error.
  Future<T> get<T>(
    Query<T> query, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _send(query, headers: headers);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);

        return query.resultFactory(json);
      } catch (e) {
        throw CQRSException(
          response,
          'An error occured while decoding response body JSON:\n$e',
        );
      }
    }

    throw CQRSException(
      response,
      'Invalid, non 200 status code returned by ${query.getFullName()} query.',
    );
  }

  /// Send a command to the backend and get the results of running it, that is
  /// whether it was successful and validation errors if there were any.
  ///
  /// Headers provided in `headers` are on top of the `headers` from the [CQRS]
  /// constructor, meaning `headers` override `_headers`. `Content-Type` header
  /// will be ignored.
  ///
  /// A [CQRSException] will be thrown in case of an error.
  Future<CommandResult> run(
    Command command, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _send(command, headers: headers);

    if ([200, 422].contains(response.statusCode)) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        return CommandResult.fromJson(json);
      } catch (e) {
        throw CQRSException(
          response,
          'An error occured while decoding response body JSON:\n$e',
        );
      }
    }

    throw CQRSException(
      response,
      'Invalid, non 200 or 422 status code returned '
      'by ${command.getFullName()} command.',
    );
  }

  Future<http.Response> _send(
    CQRSMethod cqrsMethod, {
    Map<String, String> headers = const {},
  }) async {
    return _client.post(
      _apiUri.resolve('${cqrsMethod.pathPrefix}/${cqrsMethod.getFullName()}'),
      body: jsonEncode(cqrsMethod),
      headers: {
        ..._headers,
        ...headers,
        'Content-Type': 'application/json',
      },
    ).timeout(_timeout);
  }
}
