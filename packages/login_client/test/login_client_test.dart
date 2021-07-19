import 'package:http/http.dart'
    show
        BaseRequest,
        MultipartRequest,
        Request,
        StreamedRequest,
        StreamedResponse;
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

    test(
      'send() refreshes credentials on 401 response',
      () async {
        final request = Request('POST', Uri.parse('http://www.example.com'));
        final mockOauthClient = MockClient();

        when(mockOauthClient.send(any))
            .thenAnswer((_) async => StreamedResponse(
                  const Stream.empty(),
                  200,
                ));

        when(mockOauthClient.send(request))
            .thenAnswer((_) async => StreamedResponse(
                  const Stream.empty(),
                  401,
                  request: request,
                ));

        when(mockOauthClient.refreshCredentials(any))
            .thenAnswer((_) async => mockOauthClient);

        loginClient.setAuthorizedClient(mockOauthClient);

        await loginClient.send(request);

        verify(mockOauthClient.refreshCredentials(any)).called(1);
      },
    );

    test(
      'send() throws exception when response is 401 and second response is also 401',
      () async {
        final request = Request('POST', Uri.parse('http://www.example.com'));
        final mockOauthClient = MockClient();

        when(mockOauthClient.send(any))
            .thenAnswer((_) async => StreamedResponse(
                  const Stream.empty(),
                  401,
                ));

        when(mockOauthClient.refreshCredentials(any))
            .thenAnswer((_) async => mockOauthClient);

        loginClient.setAuthorizedClient(mockOauthClient);

        expectLater(loginClient.send(request), throwsException);
      },
    );

    test(
      'copyRequest copies http.Request objects properly',
      () {
        final request = Request('POST', Uri.parse('http://www.example.com'));
        final copy = LoginClient.copyRequest(request) as Request;

        expect(copy.headers.entries, containsAll(request.headers.entries));
        expect(copy.headers.length, request.headers.length);
        expect(copy.bodyBytes, request.bodyBytes);
        expect(copy.encoding, request.encoding);
        expect(copy.method, request.method);
        expect(copy.url, request.url);
        expect(copy.persistentConnection, request.persistentConnection);
        expect(copy.followRedirects, request.followRedirects);
        expect(copy.maxRedirects, request.maxRedirects);

        expect(copy.finalized, false);
      },
    );

    test(
      'copyRequest copies http.MultipartRequest objects properly',
      () {
        final request =
            MultipartRequest('post', Uri.parse('http://www.example.com'));
        final copy = LoginClient.copyRequest(request) as MultipartRequest;

        expect(copy.headers.entries, containsAll(request.headers.entries));
        expect(copy.headers.length, request.headers.length);
        expect(copy.fields.entries, containsAll(request.fields.entries));
        expect(copy.fields.length, request.fields.length);
        expect(copy.files, containsAll(request.files));
        expect(copy.files.length, request.files.length);
        expect(copy.method, request.method);
        expect(copy.url, request.url);
        expect(copy.persistentConnection, request.persistentConnection);
        expect(copy.followRedirects, request.followRedirects);
        expect(copy.maxRedirects, request.maxRedirects);

        expect(copy.finalized, false);
      },
    );

    test(
      'copyRequest throws exception on unsupported request type',
      () {
        final request =
            StreamedRequest('POST', Uri.parse('http://www.example.com'));

        expect(() => LoginClient.copyRequest(request), throwsException);
      },
    );
  });
}

class MockLogger extends Mock {
  void call(String log) => noSuchMethod(Invocation.method(#call, [log]));
}

class FakeRequest extends Fake implements BaseRequest {}
