import 'package:leancode_logging/logger.dart';
import 'package:leancode_login_client/src/models/api_consts.dart';
import 'package:leancode_login_client/src/models/auth_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

class AssertionStrategy extends AuthStrategy {
  AssertionStrategy(this.grantName, this.assertionToken);

  final String grantName;
  final String assertionToken;

  @override
  Future<Client> execute(ApiConsts apiConsts, http.Client client) {
    logger.logInfo('Logging in with assertion token');

    return assertionGrant(
      apiConsts.authEndpoint,
      grantName,
      assertionToken,
      identifier: apiConsts.authClientId,
      secret: apiConsts.authSecret,
      scopes: apiConsts.authScopes,
      httpClient: client,
    );
  }
}
