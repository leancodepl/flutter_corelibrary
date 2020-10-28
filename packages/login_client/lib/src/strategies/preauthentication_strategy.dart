import 'package:leancode_logging/logger.dart';
import 'package:leancode_login_client/src/models/api_consts.dart';
import 'package:leancode_login_client/src/models/auth_strategy.dart';
import 'package:leancode_login_client/src/models/token.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

class PreauthenticationStrategy extends AuthStrategy {
  PreauthenticationStrategy(this.token);

  final Token token;

  @override
  Future<Client> execute(ApiConsts apiConsts, http.Client client) {
    logger.logInfo('Logging in with preauthenticated token');

    return Future.value(
      Client(
        Credentials(
          token.accessToken,
          refreshToken: token.refreshToken,
          tokenEndpoint: apiConsts.authEndpoint,
          scopes: apiConsts.authScopes,
          expiration: token.expiration,
        ),
        identifier: apiConsts.authClientId,
        secret: apiConsts.authSecret,
      ),
    );
  }
}
