import 'package:http/http.dart' show BaseRequest;
import 'package:mockito/mockito.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';

import 'package:login_client/login_client.dart';

void main() {
  group('LoginClient', () {
    OAuthSettings oAuthSettings;
    CredentialsStorage credentialsStorage;
    CredentialsChangedCallback credentialsChangedCallback;
    void Function(String) logger;
    LoginClient loginClient;
    setUp(() {
      oAuthSettings = MockOAuthSettings();
      credentialsStorage = MockCredentialsStorage();
      credentialsChangedCallback = MockCredentialsChangedCallback();
      logger = MockLogger();
      loginClient = LoginClient(
        oAuthSettings: oAuthSettings,
        credentialsStorage: credentialsStorage,
        credentialsChangedCallback: credentialsChangedCallback,
        logger: logger,
      );
    });

    test(
      'initialize() reads from storage, calls the callback and logs',
      () async {
        final credentials = Credentials('some token');

        when(credentialsStorage.read()).thenAnswer((_) async => credentials);

        await loginClient.initialize();

        expect(loginClient.loggedIn, true);

        verify(credentialsStorage.read()).called(1);
        verify(credentialsChangedCallback(credentials)).called(1);
        verify(logger('Successfully initialized with credentials.')).called(1);
      },
    );

    test(
      'logIn() calls callbacks, saves credentials and logs on success',
      () async {
        final client = MockOAuthClient();
        final strategy = MockAuthorizationStrategy();
        when(strategy.execute(any, any, any)).thenAnswer((_) async => client);

        await loginClient.logIn(strategy);

        expect(loginClient.loggedIn, true);

        verify(credentialsChangedCallback(client.credentials)).called(1);
        verify(credentialsStorage.save(client.credentials)).called(1);
        verify(logger('Successfully logged in and saved the credentials.'))
            .called(1);
      },
    );

    test(
      'logIn() logs out, logs and rethrows on AuthorizationException',
      () async {
        final authorizationException =
            AuthorizationException('Error', 'Description', Uri());

        final strategy = MockAuthorizationStrategy();
        when(strategy.execute(any, any, any)).thenThrow(authorizationException);

        await expectLater(
          loginClient.logIn(strategy),
          throwsA(isA<AuthorizationException>()),
        );

        expect(loginClient.loggedIn, false);

        verify(credentialsChangedCallback(null)).called(1);
        verify(credentialsStorage.clear()).called(1);
        verify(logger(
          'An error while logging in occured, '
          'successfully logged out and cleared credentials.',
        )).called(1);
      },
    );

    test('refresh() throws on unauthorized client', () async {
      expectLater(
        loginClient.refresh(),
        throwsA(isA<RefreshException>()),
      );
    });

    test('refresh() calls the refresh credentials', () async {
      final authorizedClient = MockOAuthClient();
      final refreshedClient = MockOAuthClient();
      when(authorizedClient.refreshCredentials(any))
          .thenAnswer((_) async => refreshedClient);

      loginClient.setAuthorizedClient(authorizedClient);
      await loginClient.refresh();

      expect(loginClient.loggedIn, true);

      verify(authorizedClient.refreshCredentials(any)).called(1);
    });

    test('logOut() logs out, calls callback and logs', () async {
      await loginClient.logOut();

      expect(loginClient.loggedIn, false);

      verify(credentialsChangedCallback(null)).called(1);
      verify(credentialsStorage.clear()).called(1);
      verify(logger('Successfully logged out and cleared the credentials.'))
          .called(1);
    });

    test(
      'send() logs out, logs and rethrows on AuthorizationException',
      () async {
        final request = FakeRequest();
        final mockOauthClient = MockOAuthClient();
        when(mockOauthClient.send(request))
            .thenThrow(AuthorizationException('Error', 'Description', Uri()));

        loginClient.setAuthorizedClient(mockOauthClient);

        await expectLater(
          loginClient.send(request),
          throwsA(isA<AuthorizationException>()),
        );

        expect(loginClient.loggedIn, false);

        verify(credentialsChangedCallback(null)).called(1);
        verify(credentialsStorage.clear()).called(1);
        verify(logger(
          'An error while sending a request occured, '
          'successfully logged out and cleared credentials.',
        )).called(1);
      },
    );
  });
}

class MockOAuthSettings extends Mock implements OAuthSettings {}

class MockCredentialsStorage extends Mock implements CredentialsStorage {}

class MockCredentialsChangedCallback extends Mock {
  void call(Credentials credentials) =>
      noSuchMethod(Invocation.method(#call, [credentials]));
}

class MockLogger extends Mock {
  void call(String log) => noSuchMethod(Invocation.method(#call, [log]));
}

class MockAuthorizationStrategy extends Mock implements AuthorizationStrategy {}

class MockOAuthClient extends Mock implements Client {
  @override
  final credentials = Credentials('fake access token');
}

class FakeRequest extends Fake implements BaseRequest {}
