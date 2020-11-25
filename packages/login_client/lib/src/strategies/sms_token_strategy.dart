import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../oauth2/sms_token_grant.dart';
import '../oauth_settings.dart';
import 'authorization_strategy.dart';

class SmsTokenStrategy extends AuthorizationStrategy {
  SmsTokenStrategy(this.username, this.smsToken);

  final String username;
  final String smsToken;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return smsTokenGrant(
      oAuthSettings.authorizationEndpointUri,
      username,
      smsToken,
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
