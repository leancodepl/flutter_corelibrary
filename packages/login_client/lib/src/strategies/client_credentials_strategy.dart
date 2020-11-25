import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../oauth_settings.dart';
import 'authorization_strategy.dart';

class ClientCredentialsStrategy extends AuthorizationStrategy {
  ClientCredentialsStrategy(this.username, this.password);

  final String username;
  final String password;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed, // not used
  ) {
    return oauth2.clientCredentialsGrant(
      oAuthSettings.authorizationEndpointUri,
      oAuthSettings.clientId,
      oAuthSettings.clientSecret,
      scopes: oAuthSettings.scopes,
      httpClient: client,
    );
  }
}
