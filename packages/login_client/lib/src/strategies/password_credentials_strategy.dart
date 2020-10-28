import 'package:http/http.dart' as http;
import 'package:leancode_logging/logger.dart';
import 'package:leancode_login_client/src/models/api_consts.dart';
import 'package:leancode_login_client/src/models/auth_strategy.dart';
import 'package:oauth2/oauth2.dart';

class PasswordCredentialsStrategy extends AuthStrategy {
  PasswordCredentialsStrategy(this.username, this.password);

  final String username;
  final String password;

  @override
  Future<Client> execute(ApiConsts apiConsts, http.Client client) {
    logger.logInfo('Logging in with password');

    return resourceOwnerPasswordGrant(
      apiConsts.authEndpoint,
      username,
      password,
      identifier: apiConsts.authClientId,
      secret: apiConsts.authSecret,
      scopes: apiConsts.authScopes,
      httpClient: client,
    );
  }
}
