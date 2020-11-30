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

class CustomGrantStrategy extends AuthorizationStrategy {
  CustomGrantStrategy(
    this.grantName,
    this.tokenFieldName,
    this.tokenFieldValue,
  ) : assert(
          !['password', 'client_credentials', 'sms_token'].contains(grantName),
          'You cannot use reserved grant name in a CustomGrantStrategy.',
        );

  final String grantName;
  final String tokenFieldName;
  final String tokenFieldValue;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return customGrant(
      oAuthSettings.authorizationEndpointUri,
      grantName,
      tokenFieldName,
      tokenFieldValue,
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
