// Copyright 2021 LeanCode Sp. z o.o.
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

// ignore_for_file: implementation_imports

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth2/src/handle_access_token_response.dart';
import 'package:oauth2/src/utils.dart';

Future<Client> customGrant(
  Uri authorizationEndpoint,
  String grantName,
  Map<String, String> grantFields, {
  String? identifier,
  String? secret,
  Iterable<String>? scopes,
  bool basicAuth = true,
  CredentialsRefreshedCallback? onCredentialsRefreshed,
  http.Client? httpClient,
  String delimiter = ' ',
  Map<String, dynamic> Function(MediaType? contentType, String body)?
      getParameters,
}) async {
  httpClient ??= http.Client();

  final startTime = DateTime.now();
  final body = {'grant_type': grantName, ...grantFields};
  final headers = <String, String>{};

  if (identifier != null) {
    if (basicAuth) {
      headers['Authorization'] = basicAuthHeader(identifier, secret!);
    } else {
      body['client_id'] = identifier;
      if (secret != null) {
        body['client_secret'] = secret;
      }
    }
  }

  if (scopes != null && scopes.isNotEmpty) {
    body['scope'] = scopes.join(delimiter);
  }

  final response = await httpClient.post(
    authorizationEndpoint,
    headers: headers,
    body: body,
  );

  final credentials = handleAccessTokenResponse(
    response,
    authorizationEndpoint,
    startTime,
    scopes?.toList(),
    delimiter,
    getParameters: getParameters,
  );

  return Client(
    credentials,
    identifier: identifier,
    secret: secret,
    httpClient: httpClient,
    onCredentialsRefreshed: onCredentialsRefreshed,
  );
}
