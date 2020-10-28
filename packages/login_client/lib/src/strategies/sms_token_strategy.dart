import 'package:leancode_logging/logger.dart';
import 'package:leancode_login_client/src/models/api_consts.dart';
import 'package:leancode_login_client/src/models/auth_strategy.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;

class SMSTokenStrategy extends AuthStrategy {
  SMSTokenStrategy(this.username, this.smsCode);

  final String username;
  final String smsCode;

  @override
  Future<Client> execute(ApiConsts apiConsts, http.Client client) {
    logger.logInfo('Logging in with sms token');

    return smsTokenGrant(
      apiConsts.authEndpoint,
      username,
      smsCode,
      identifier: apiConsts.authClientId,
      secret: apiConsts.authSecret,
      scopes: apiConsts.authScopes,
      httpClient: client,
    );
  }
}
