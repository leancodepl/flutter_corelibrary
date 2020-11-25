import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import 'oauth_settings.dart';

oauth2.Client buildOAuth2ClientFromCredentials(
  oauth2.Credentials credentials, {
  OAuthSettings oAuthSettings,
  http.Client httpClient,
  oauth2.CredentialsRefreshedCallback onCredentialsRefreshed,
}) {
  return oauth2.Client(
    credentials,
    identifier: oAuthSettings?.clientId,
    secret: oAuthSettings?.clientSecret,
    httpClient: httpClient,
    onCredentialsRefreshed: onCredentialsRefreshed,
  );
}
