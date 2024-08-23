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

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth2/oauth2.dart';

import 'oauth_settings.dart';

/// Creates a new client from [oauth2.Credentials] and [OAuthSettings].
///
/// [httpClient] is the underlying client that this forwards requests to after
/// adding authorization credentials to them.
oauth2.Client buildOAuth2ClientFromCredentials(
  oauth2.Credentials credentials, {
  OAuthSettings? oAuthSettings,
  http.Client? httpClient,
  oauth2.CredentialsRefreshedCallback? onCredentialsRefreshed,
}) {
  return oauth2.Client(
    credentials,
    identifier: oAuthSettings?.clientId,
    secret: oAuthSettings?.clientSecret,
    httpClient: httpClient,
    onCredentialsRefreshed: onCredentialsRefreshed,
  );
}

/// Extension methods for the [Credentials] class.
extension CredentialsExt on Credentials {
  /// Creates a copy of the current [Credentials] with the provided [tokenEndpoint].
  Credentials copyWithTokenEndpoint(Uri newTokenEndpoint) {
    return Credentials(
      accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      tokenEndpoint: newTokenEndpoint,
      scopes: scopes,
      expiration: expiration,
    );
  }
}
