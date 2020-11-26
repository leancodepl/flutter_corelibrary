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
