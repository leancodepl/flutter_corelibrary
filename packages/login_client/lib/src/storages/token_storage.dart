import 'package:leancode_login_client/src/models/models.dart';

abstract class TokenStorage {
  const TokenStorage();

  Future<Token> getToken();
  Future<void> setToken(Token token);
  Future<void> wipeToken();
}
