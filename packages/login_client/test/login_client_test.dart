import 'package:http/http.dart' show BaseRequest;
import 'package:login_client/login_client.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oauth2/oauth2.dart';
import 'package:test/test.dart';

import 'login_client_test.mocks.dart';

@GenerateMocks([
  AuthorizationStrategy,
  CredentialsStorage,
  Client,
  OAuthSettings,
])
void main() {
  group('LoginClient', () {
    late OAuthSettings oAuthSettings;
    late CredentialsStorage credentialsStorage;
    late void Function(String) logger;
    late LoginClient loginClient;
    setUp(() {
      oAuthSettings = MockOAuthSettings();
      when(oAuthSettings.clientId).thenReturn('client id');
      when(oAuthSettings.clientSecret).thenReturn('client secret');
      credentialsStorage = MockCredentialsStorage();
      logger = MockLogger();
      loginClient = LoginClient(
        oAuthSettings: oAuthSettings,
        credentialsStorage: credentialsStorage,
        logger: logger,
      );
    });

    test(
      'initialize() reads from storage, calls the callback and logs',
      () async {
        final credentials = Credentials('some token');

        when(credentialsStorage.read()).thenAnswer((_) async => credentials);

        expectLater(loginClient.onCredentialsChanged, emits(credentials));

        await loginClient.initialize();

        expect(loginClient.loggedIn, true);

        verify(credentialsStorage.read()).called(1);
        verify(logger('Successfully initialized with credentials.')).called(1);
      },
    );

    test(
      'logIn() calls callbacks, saves credentials and logs on success',
      () async {
        final client = MockClient();
        final credentials = Credentials('access token');
        when(client.credentials).thenReturn(credentials);
        final strategy = MockAuthorizationStrategy();
        when(strategy.execute(any, any, any)).thenAnswer((_) async => client);

        expectLater(
          loginClient.onCredentialsChanged,
          emits(credentials),
        );

        await loginClient.logIn(strategy);

        expect(loginClient.loggedIn, true);

        verify(credentialsStorage.save(credentials)).called(1);
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

        expectLater(loginClient.onCredentialsChanged, emits(null));

        await expectLater(
          loginClient.logIn(strategy),
          throwsA(isA<AuthorizationException>()),
        );

        expect(loginClient.loggedIn, false);

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
      final authorizedClient = MockClient();
      final refreshedClient = MockClient();
      when(authorizedClient.refreshCredentials(any))
          .thenAnswer((_) async => refreshedClient);

      loginClient.setAuthorizedClient(authorizedClient);
      await loginClient.refresh();

      expect(loginClient.loggedIn, true);

      verify(authorizedClient.refreshCredentials(any)).called(1);
    });

    test('logOut() logs out, calls callback and logs', () async {
      expectLater(loginClient.onCredentialsChanged, emits(null));

      await loginClient.logOut();

      expect(loginClient.loggedIn, false);

      verify(credentialsStorage.clear()).called(1);
      verify(logger('Successfully logged out and cleared the credentials.'))
          .called(1);
    });

    test(
      'send() logs out, logs and rethrows on AuthorizationException',
      () async {
        final request = FakeRequest();
        final mockOauthClient = MockClient();
        when(mockOauthClient.send(request))
            .thenThrow(AuthorizationException('Error', 'Description', Uri()));

        loginClient.setAuthorizedClient(mockOauthClient);

        expectLater(loginClient.onCredentialsChanged, emits(null));

        await expectLater(
          loginClient.send(request),
          throwsA(isA<AuthorizationException>()),
        );

        expect(loginClient.loggedIn, false);

        verify(credentialsStorage.clear()).called(1);
        verify(logger(
          'An error while sending a request occured, '
          'successfully logged out and cleared credentials.',
        )).called(1);
      },
    );
  });
}

class MockLogger extends Mock {
  void call(String log) => noSuchMethod(Invocation.method(#call, [log]));
}

class FakeRequest extends Fake implements BaseRequest {}
