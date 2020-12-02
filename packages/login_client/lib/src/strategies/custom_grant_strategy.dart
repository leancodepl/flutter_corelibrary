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

import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../oauth2/custom_grant.dart';
import '../oauth_settings.dart';
import 'authorization_strategy.dart';

/// An [AuthorizationStrategy] that authorizes using a custom grant with
/// a customized token field.
class CustomGrantStrategy implements AuthorizationStrategy {
  /// Creates the [CustomGrantStrategy].
  ///
  /// The [grantName] is the custom grant name.
  ///
  /// The [grantFields] are the key-value pairs sent in the access
  /// token request.
  const CustomGrantStrategy(this.grantName, this.grantFields);

  /// The custom grant name.
  ///
  /// You should not use grant names that are already defined in the OAuth2:
  /// https://tools.ietf.org/html/rfc6749#appendix-A.10
  final String grantName;

  /// The custom grant custom fields.
  final Map<String, String> grantFields;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return customGrant(
      oAuthSettings.authorizationUri,
      grantName,
      grantFields,
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
