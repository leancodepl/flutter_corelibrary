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

import '../oauth2/custom_grant.dart';
import '../oauth_settings.dart';
import 'authorization_strategy.dart';

/// An [AuthorizationStrategy] that uses a phone number and an SMS token to
/// authorize the resource owner.
class SmsTokenStrategy implements AuthorizationStrategy {
  /// Creates the [SmsTokenStrategy].
  ///
  /// The [phoneNumber] is the resource owner phone number. The [smsToken] is
  /// the resource owner SMS token received on the [phoneNumber].
  const SmsTokenStrategy(this.phoneNumber, this.smsToken);

  static const _grantName = 'sms_token';

  /// The resource owner phone number.
  final String phoneNumber;

  /// The resource owner SMS token received on the [phoneNumber].
  final String smsToken;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return customGrant(
      oAuthSettings.authorizationUri,
      _grantName,
      {'phone_number': phoneNumber, 'token': smsToken},
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
