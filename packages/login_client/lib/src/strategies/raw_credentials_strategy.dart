import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import '../oauth_settings.dart';
import '../utils.dart';
import 'authorization_strategy.dart';

class RawCredentialsStrategy extends AuthorizationStrategy {
  RawCredentialsStrategy(this.credentials);

  final oauth2.Credentials credentials;

  @override
  Future<oauth2.Client> execute(
    OAuthSettings oAuthSettings,
    http.Client client,
    oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
  ) {
    return Future.value(
      buildOAuth2ClientFromCredentials(
        credentials,
        oAuthSettings: oAuthSettings,
        httpClient: client,
        onCredentialsRefreshed: onCredentialsRefreshed,
      ),
    );
  }
}
