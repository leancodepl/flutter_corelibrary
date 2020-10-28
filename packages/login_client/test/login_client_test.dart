import 'package:flutter_test/flutter_test.dart';
import 'package:leancode_login_client/leancode_login_client.dart';
import 'package:leancode_login_client/src/models/models.dart';
import 'package:leancode_login_client/src/strategies/assertion_strategy.dart';
import 'package:leancode_login_client/src/strategies/password_credentials_strategy.dart';
import 'package:leancode_login_client/src/strategies/preauthentication_strategy.dart';
import 'package:leancode_login_client/src/strategies/sms_token_strategy.dart';
import 'package:mockito/mockito.dart';
import 'package:leancode_logging/logger.dart';
import 'package:oauth2/oauth2.dart' as auth;
import 'package:http/http.dart' as http;

class FakeLogger extends Mock implements Logger {}

class FakeAuthClient extends Mock implements auth.Client {}

class FakeClient extends Mock implements http.Client {}

class FakeRequest extends Mock implements http.BaseRequest {}

class FakeResponse extends Mock implements http.StreamedResponse {}

class FakeTokenStorage extends Mock implements TokenStorage {}

class FakePasswordCredentialsStrategy extends Mock
    implements PasswordCredentialsStrategy {}

class FakeAssertionStrategy extends Mock implements AssertionStrategy {}

class FakeSMSTokenStrategy extends Mock implements SMSTokenStrategy {}

class FakePreauthenticationStrategy extends Mock
    implements PreauthenticationStrategy {}

void main() {
  group('Api client tests', () {
    final client = FakeClient();
    final authClient = FakeAuthClient();
    final fakeTokenStorage = FakeTokenStorage();
    final fakeRequest = FakeRequest();
    final fakeResponse = FakeResponse();

    final passwordCredentialsStrategy = FakePasswordCredentialsStrategy();
    final smsTokenStrategy = FakeSMSTokenStrategy();
    final assertionStrategy = FakeAssertionStrategy();

    final token = Token()
      ..accessToken = 'access_token'
      ..refreshToken = 'refresh_token';

    final newToken = Token()
      ..accessToken = 'new_access_token'
      ..refreshToken = 'new_refresh_token';

    OAuthLoginClient apiClient;

    setUpAll(() {
      logger = FakeLogger();

      when(passwordCredentialsStrategy.execute(any, any))
          .thenAnswer((_) async => authClient);

      when(smsTokenStrategy.execute(any, any))
          .thenAnswer((_) async => authClient);

      when(assertionStrategy.execute(any, any))
          .thenAnswer((_) async => authClient);
    });

    setUp(() async {
      apiClient = OAuthLoginClient(
        client,
        ApiConsts(),
        fakeTokenStorage,
        generateClientFromToken: (_) => authClient,
      );
    });

    test('Should login and use authorized client when initializing with token.',
        () async {
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);

      final apiClient = OAuthLoginClient(
        client,
        ApiConsts(),
        fakeTokenStorage,
      );

      await apiClient.initializeAsync();

      final auth.Client authClient = apiClient.client;

      expect(authClient.credentials.accessToken, token.accessToken);
      expect(apiClient.isLoggedIn, true);
    });

    test(
        'Should logout and use unauthorized client when initializing without token.',
        () async {
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => null);

      await apiClient.initializeAsync();

      expect(apiClient.client, client);
      expect(apiClient.isLoggedIn, false);
    });

    test(
        'Should login, save token and use authorized client when logging in with password.',
        () async {
      when(authClient.credentials).thenAnswer((_) => auth.Credentials(
          token.accessToken,
          refreshToken: token.refreshToken));

      final result = await apiClient.login(passwordCredentialsStrategy);

      expect(result, isA<Success>());
      verify(fakeTokenStorage.setToken(argThat(predicate<Token>((t) {
        return t.accessToken == token.accessToken &&
            t.refreshToken == token.refreshToken;
      })))).called(1);
      expect(apiClient.client, authClient);
      expect(apiClient.isLoggedIn, true);
    });

    test(
        'Should login, save token and use authorized client when logging in with assertion token.',
        () async {
      when(authClient.credentials).thenAnswer((_) => auth.Credentials(
          token.accessToken,
          refreshToken: token.refreshToken));

      final result = await apiClient.login(assertionStrategy);

      expect(result, isA<Success>());
      verify(fakeTokenStorage.setToken(argThat(predicate<Token>((t) {
        return t.accessToken == token.accessToken &&
            t.refreshToken == token.refreshToken;
      })))).called(1);
      expect(apiClient.client, authClient);
      expect(apiClient.isLoggedIn, true);
    });

    test(
        'Should login, save token and use authorized client when logging in with sms token.',
        () async {
      when(authClient.credentials).thenAnswer((_) => auth.Credentials(
          token.accessToken,
          refreshToken: token.refreshToken));

      final result = await apiClient.login(smsTokenStrategy);

      expect(result, isA<Success>());
      verify(fakeTokenStorage.setToken(argThat(predicate<Token>((t) {
        return t.accessToken == token.accessToken &&
            t.refreshToken == token.refreshToken;
      })))).called(1);
      expect(apiClient.client, authClient);
      expect(apiClient.isLoggedIn, true);
    });

    test(
        'Should logout and use unauthorized client when logging in with incorrect password.',
        () async {
      when(passwordCredentialsStrategy.execute(any, any))
          .thenThrow(auth.AuthorizationException('', '', null));

      final result = await apiClient.login(passwordCredentialsStrategy);

      expect(result, isA<AuthorizationFailed>());
      expect(apiClient.client, client);
      expect(apiClient.isLoggedIn, false);
    });

    test(
        'Should logout and use unauthorized client when logging in with incorrect assertion token.',
        () async {
      when(assertionStrategy.execute(any, any))
          .thenThrow(auth.AuthorizationException('', '', null));

      final result = await apiClient.login(assertionStrategy);

      expect(result, isA<AuthorizationFailed>());
      expect(apiClient.client, client);
      expect(apiClient.isLoggedIn, false);
    });

    test(
        'Should logout and use unauthorized client when logging in with incorrect sms token.',
        () async {
      when(smsTokenStrategy.execute(any, any))
          .thenThrow(auth.AuthorizationException('', '', null));

      final result = await apiClient.login(smsTokenStrategy);

      expect(result, isA<AuthorizationFailed>());
      expect(apiClient.client, client);
      expect(apiClient.isLoggedIn, false);
    });

    test('Should wipe token when logout', () async {
      when(authClient.credentials).thenAnswer((_) => auth.Credentials(
          token.accessToken,
          refreshToken: token.refreshToken));
      await apiClient.login(passwordCredentialsStrategy);

      await apiClient.logout();

      verify(fakeTokenStorage.wipeToken()).called(1);
      expect(apiClient.client, client);
      expect(apiClient.isLoggedIn, false);
    });

    test('Should return cannotBeRefreshed when client is unauthorized',
        () async {
      final result = await apiClient.refreshToken();

      expect(result, isA<CannotBeRefreshed>());
    });

    test('Should refresh, save token and use authorized client', () async {
      final credentials = auth.Credentials(token.accessToken,
          refreshToken: token.refreshToken, tokenEndpoint: Uri());

      when(authClient.credentials).thenAnswer((_) => credentials);
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);
      when(authClient.refreshCredentials()).thenAnswer((_) async => authClient);

      await apiClient.initializeAsync();

      final result = await apiClient.refreshToken();

      expect(result, isA<Success>());
      verify(fakeTokenStorage.setToken(argThat(predicate<Token>((t) {
        return t.accessToken == token.accessToken &&
            t.refreshToken == token.refreshToken;
      })))).called(1);
    });

    test(
        'Should return unexpectedOAuthError when refreshCredentials throws exceptions',
        () async {
      final credentials = auth.Credentials(token.accessToken,
          refreshToken: token.refreshToken, tokenEndpoint: Uri());

      when(authClient.credentials).thenAnswer((_) => credentials);
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);
      when(authClient.refreshCredentials())
          .thenThrow(const FormatException('', '', null));

      await apiClient.initializeAsync();

      final result = await apiClient.refreshToken();
      expect(result, isA<UnexpectedOAuthError>());
    });

    test(
        'Should return invalidGrant when refreshCredentials throws authorization exception',
        () async {
      final credentials = auth.Credentials(token.accessToken,
          refreshToken: token.refreshToken, tokenEndpoint: Uri());

      when(authClient.credentials).thenAnswer((_) => credentials);
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);
      when(authClient.refreshCredentials())
          .thenThrow(auth.AuthorizationException('', '', null));

      await apiClient.initializeAsync();

      final result = await apiClient.refreshToken();
      expect(result, isA<AuthorizationFailed>());
    });

    test('Should save new token when old expires', () async {
      // Initialize auth client.
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);
      await apiClient.initializeAsync();

      // Simulate token refresh.
      when(authClient.credentials).thenAnswer((_) => auth.Credentials(
          newToken.accessToken,
          refreshToken: newToken.refreshToken));

      when(authClient.send(any)).thenAnswer((_) async => fakeResponse);

      await apiClient.send(fakeRequest);

      verify(fakeTokenStorage.setToken(argThat(predicate<Token>((t) {
        return t.accessToken == newToken.accessToken &&
            t.refreshToken == newToken.refreshToken;
      })))).called(1);
    });

    test('Should logout when send throws authorization exception', () async {
      when(fakeTokenStorage.getToken()).thenAnswer((_) async => token);
      await apiClient.initializeAsync();
      when(authClient.send(any))
          .thenThrow(auth.AuthorizationException('', '', null));

      await expectLater(apiClient.send(fakeRequest),
          throwsA(isA<auth.AuthorizationException>()));
      expect(apiClient.isLoggedIn, false);
    });

    tearDown(() {
      apiClient.close();
    });
  });
}
