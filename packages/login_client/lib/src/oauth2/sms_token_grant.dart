// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: implementation_imports

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth2/src/handle_access_token_response.dart';
import 'package:oauth2/src/utils.dart';

Future<Client> smsTokenGrant(
  Uri authorizationEndpoint,
  String phoneNumber,
  String smsToken, {
  String identifier,
  String secret,
  Iterable<String> scopes,
  bool basicAuth = true,
  CredentialsRefreshedCallback onCredentialsRefreshed,
  http.Client httpClient,
  String delimiter = ' ',
  Map<String, dynamic> Function(MediaType contentType, String body)
      getParameters,
}) async {
  httpClient ??= http.Client();

  final startTime = DateTime.now();
  final body = {
    'grant_type': 'sms_token',
    'phone_number': phoneNumber,
    'token': smsToken,
  };
  final headers = <String, String>{};

  if (identifier != null) {
    if (basicAuth) {
      headers['Authorization'] = basicAuthHeader(identifier, secret);
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
    scopes.toList(),
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
