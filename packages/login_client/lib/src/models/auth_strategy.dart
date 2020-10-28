import 'package:http/http.dart' as http;
import 'package:leancode_login_client/src/models/api_consts.dart';
import 'package:oauth2/oauth2.dart';

abstract class AuthStrategy {
  Future<Client> execute(ApiConsts apiConsts, http.Client client);
}
