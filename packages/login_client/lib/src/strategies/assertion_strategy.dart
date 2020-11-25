import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../oauth2/assertion_grant.dart';
import '../oauth_settings.dart';
import 'authorization_strategy.dart';

class UserAssertionStrategy extends AuthorizationStrategy {
  UserAssertionStrategy(this.grantName, this.userToken);

  final String grantName;
  final String userToken;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return assertionGrant(
      oAuthSettings.authorizationEndpointUri,
      grantName,
      userToken,
      identifier: oAuthSettings.clientId,
      secret: oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
      onCredentialsRefreshed: onCredentialsRefreshed,
    );
  }
}
