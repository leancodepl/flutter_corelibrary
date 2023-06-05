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

import '../oauth_settings.dart';
import 'authorization_strategy.dart';

/// An [AuthorizationStrategy] that uses the Resource Owner Password Grant.
///
/// See also:
/// - https://tools.ietf.org/html/rfc6749#section-4.3
class ResourceOwnerPasswordStrategy implements AuthorizationStrategy {
  /// Creates the [ResourceOwnerPasswordStrategy].
  ///
  /// The [username] is the resource owner username. The [password] is
  /// the resource owner password.
  const ResourceOwnerPasswordStrategy(this.username, this.password);

  /// The resource owner username.
  final String username;

  /// The resource owner password.
  final String password;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return oauth2.resourceOwnerPasswordGrant(
      oAuthSettings.authorizationUri,
      username,
      password,
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
