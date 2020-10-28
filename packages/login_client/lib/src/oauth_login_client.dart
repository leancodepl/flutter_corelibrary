import 'package:http/http.dart' as http;
import 'package:leancode_logging/leancode_logging.dart';
import 'package:oauth2/oauth2.dart' as auth;
import 'package:leancode_common/leancode_common.dart';
import 'package:oauth2/oauth2.dart';

import '../leancode_login_client.dart';
import 'login_state.dart';
import 'models/auth_strategy.dart';
import 'models/models.dart';
import 'models/results.dart';

const TAG = 'LoginClient';

class OAuthLoginClient extends http.BaseClient
    implements AsyncInitializable, Disposable {
  OAuthLoginClient(
      this._unauthorizedClient, this._apiConsts, this._tokenStorage,
      {this.generateClientFromToken})
      : _loginState = LoginState();

  final http.Client _unauthorizedClient;
  final ApiConsts _apiConsts;
  final TokenStorage _tokenStorage;
  final LoginState _loginState;

  final Client Function(Token) generateClientFromToken;

  auth.Client _authorizedClient;
  http.Client get client => _authorizedClient ?? _unauthorizedClient;

  bool get isLoggedIn => _loginState.isLoggedIn;
  Stream<bool> get onLoggedInChange => _loginState.onLoggedInChange;

  Future<LoginResult> login(AuthStrategy strategy) async {
    try {
      _authorizedClient =
          await strategy.execute(_apiConsts, _unauthorizedClient);

      if (!_validateAuthorizedClient(_authorizedClient)) {
        return const UnexpectedOAuthError();
      }

      logger.logInfo('$TAG. Successfully logged in.');

      final token = _buildTokenFromCredentials(_authorizedClient.credentials);

      await _setToken(token);

      return const Success();
    } on auth.AuthorizationException catch (e) {
      logger.logWarning('$TAG. Logging in failed. $e');
      _authorizedClient = null;
      return AuthorizationFailed.fromException(e);
    } catch (e, t) {
      logger.logError(
          '$TAG. Logging in failed unexpectedly. Error: $e. Stacktrace: $t');
      _authorizedClient = null;
      return const UnexpectedOAuthError();
    }
  }

  Future<void> logout() async {
    try {
      logger.logInfo('$TAG. Logging out.');

      await _setToken(null);

      _authorizedClient = null;
    } catch (e, t) {
      logger.logError(
          '$TAG. Unexpected error occurred when logging out. Error: $e. Stacktrace: $t');
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    http.BaseResponse response;

    try {
      response = await client?.send(request);
    } on auth.AuthorizationException catch (e, t) {
      logger.logWarning(
          '$TAG. Authorization failure for request ${request.url}. $e. Stacktrace: $t');

      _authorizedClient = null;

      await _setToken(null);

      rethrow;
    } catch (e, t) {
      logger.logWarning(
          '$TAG. Sending request to ${request.url} unexpectedly failed . $e. Stacktrace: $t');
      rethrow;
    }

    if (_authorizedClient != null &&
        _hasTokenChanged(
            _loginState.currenToken, _authorizedClient.credentials)) {
      try {
        logger.logInfo(
            '$TAG. Token has been updated. Saving new token in storage.');
        final token = _buildTokenFromCredentials(_authorizedClient.credentials);

        await _setToken(token);
      } catch (e, t) {
        logger.logError(
            '$TAG. Unexpected error occurred when saving new token in storage. Error: $e. Stacktrace: $t');
      }
    }

    return response;
  }

  Future<RefreshResult> refreshToken() async {
    if (_authorizedClient?.credentials?.canRefresh != true) {
      return const CannotBeRefreshed();
    }

    try {
      await _authorizedClient.refreshCredentials();

      if (!_validateAuthorizedClient(_authorizedClient)) {
        return const UnexpectedOAuthError();
      }

      logger.logInfo('$TAG. Successfully refreshed.');

      final token = _buildTokenFromCredentials(_authorizedClient.credentials);

      await _setToken(token);

      return const Success();
    } on auth.AuthorizationException catch (e) {
      logger.logWarning('$TAG. Refresh failed. $e');
      return AuthorizationFailed.fromException(e);
    } catch (e, t) {
      logger.logError(
          '$TAG. Refreshing failed unexpectedly. Error: $e. Stacktrace: $t');
      return const UnexpectedOAuthError();
    }
  }

  @override
  Future<void> initializeAsync() async {
    logger.logInfo('$TAG. Initializing...');

    final _token = await _tokenStorage.getToken();

    _authorizedClient =
        _token != null ? _generateClientFromToken(_token) : null;

    _loginState.setToken(_token);
  }

  auth.Client _generateClientFromToken(Token _token) {
    if (generateClientFromToken != null) {
      return generateClientFromToken(_token);
    }

    return Client(
      Credentials(
        _token.accessToken,
        refreshToken: _token.refreshToken,
        tokenEndpoint: _apiConsts.authEndpoint,
        scopes: _apiConsts.authScopes,
        expiration: _token.expiration,
      ),
      identifier: _apiConsts.authClientId,
      secret: _apiConsts.authSecret,
    );
  }

  Future<void> _setToken(Token token) async {
    await (token != null
        ? _tokenStorage.setToken(token)
        : _tokenStorage.wipeToken());

    _loginState.setToken(token);
  }

  bool _hasTokenChanged(Token token, auth.Credentials credentials) {
    return token?.accessToken != credentials?.accessToken ||
        token?.refreshToken != credentials?.refreshToken;
  }

  Token _buildTokenFromCredentials(auth.Credentials credentials) {
    return Token()
      ..accessToken = credentials.accessToken
      ..refreshToken = credentials.refreshToken
      ..expiration = credentials.expiration;
  }

  bool _validateAuthorizedClient(auth.Client client) {
    if (_authorizedClient == null) {
      logger.logError('$TAG. Logging in failed. Client is null.');
      return false;
    }

    if (_authorizedClient.credentials == null) {
      logger
          .logError('$TAG. Logging in failed. Client\'s credentials are null.');
      _authorizedClient = null;
      return false;
    }

    if (_authorizedClient.credentials.accessToken == null) {
      logger.logError('$TAG. Logging in failed. Access token is null.');
      _authorizedClient = null;
      return false;
    }

    return true;
  }

  @override
  void dispose() => _loginState.dispose();
}
