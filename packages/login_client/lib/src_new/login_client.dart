import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import 'credentials_storage/credentials_storage.dart';
import 'oauth_settings.dart';
import 'strategies/authorization_strategy.dart';

typedef CredentialsChangedCallback = void Function(oauth2.Credentials);

typedef _LoggerCallback = void Function(String);

void _defaultPrintLogger(String message) => print('[LoginClient] $message');

class LoginClient extends http.BaseClient {
  LoginClient({
    @required OAuthSettings oAuthSettings,
    @required CredentialsStorage credentialsStorage,
    http.Client httpClient,
    CredentialsChangedCallback credentialsChangedCallback,
    _LoggerCallback loggerCallback = _defaultPrintLogger,
  })  : assert(oAuthSettings != null),
        assert(credentialsStorage != null),
        assert(_logger != null),
        _oAuthSettings = oAuthSettings,
        _httpClient = httpClient ?? http.Client(),
        _credentialsStorage = credentialsStorage,
        _credentialsChangedCallback = credentialsChangedCallback,
        _logger = loggerCallback;

  final OAuthSettings _oAuthSettings;
  final CredentialsStorage _credentialsStorage;
  final http.Client _httpClient;
  final CredentialsChangedCallback _credentialsChangedCallback;
  final _LoggerCallback _logger;

  oauth2.Client _oAuthClient;

  bool get loggedIn => _oAuthClient != null;

  Future<void> initialize() async {
    final credentials = await _credentialsStorage.read();
    if (credentials != null) {
      _oAuthClient = _buildClientFromCredentials(credentials);
    }

    _credentialsChangedCallback?.call(credentials);

    if (credentials != null) {
      _logger('Successfully initialized with credentials.');
    } else {
      _logger('Successfully initialized with no credentials.');
    }
  }

  Future<void> logIn(AuthorizationStrategy strategy) async {
    try {
      _oAuthClient = await strategy.execute(
        _oAuthSettings,
        _httpClient,
        _onCredentialsRefreshed,
      );

      _credentialsChangedCallback?.call(_oAuthClient.credentials);
      await _credentialsStorage.save(_oAuthClient.credentials);

      _logger('Successfully logged in and saved the credentials.');
    } on oauth2.AuthorizationException {
      await _logOutInternal();
      _logger('An error while logging in occured, '
          'successfully logged out and cleared credentials.');
      rethrow;
    }
  }

  Future<void> refresh([List<String> newScopes]) async {
    if (_oAuthClient == null) {
      // TODO: Use more specific exception class
      throw Exception('Cannot refresh unauthorized client. Login first.');
    }

    try {
      _oAuthClient = await _oAuthClient.refreshCredentials(newScopes);
    } on oauth2.AuthorizationException {
      await _logOutInternal();
      _logger('An error while force refreshing occured, '
          'successfully logged out and cleared credentials.');
      rethrow;
    }
  }

  Future<void> logOut() async {
    await _logOutInternal();
    _logger('Successfully logged out and cleared the credentials.');
  }

  Future<void> _logOutInternal() async {
    _credentialsChangedCallback?.call(null);
    await _credentialsStorage.clear();

    _oAuthClient.close();
    _oAuthClient = null;
  }

  oauth2.Client _buildClientFromCredentials(oauth2.Credentials credentials) {
    return oauth2.Client(
      credentials,
      identifier: _oAuthSettings.clientId,
      secret: _oAuthSettings.clientSecret,
      httpClient: _httpClient,
      onCredentialsRefreshed: _onCredentialsRefreshed,
    );
  }

  Future<void> _onCredentialsRefreshed(oauth2.Credentials credentials) async {
    _credentialsChangedCallback?.call(credentials);
    await _credentialsStorage.save(credentials);

    _logger('Successfully refreshed and saved the new credentials.');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final client = _oAuthClient ?? _httpClient;

    http.StreamedResponse response;
    try {
      response = await client.send(request);
    } on oauth2.AuthorizationException {
      await _logOutInternal();
      _logger('An error while sending a request occured, '
          'successfully logged out and cleared credentials.');
      rethrow;
    }

    return response;
  }
}