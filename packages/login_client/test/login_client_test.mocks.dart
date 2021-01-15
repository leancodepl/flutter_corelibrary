import 'dart:async' as _i4;

import 'package:http/src/client.dart' as _i6;
import 'package:login_client/src/oauth_settings.dart' as _i5;
import 'package:login_client/src/strategies/authorization_strategy.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:oauth2/src/client.dart' as _i2;
import 'package:oauth2/src/credentials.dart' as _i7;

// ignore_for_file: comment_references

// ignore_for_file: unnecessary_parenthesis

class _FakeClient extends _i1.Fake implements _i2.Client {}

/// A class which mocks [AuthorizationStrategy].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthorizationStrategy extends _i1.Mock
    implements _i3.AuthorizationStrategy {
  MockAuthorizationStrategy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Client> execute(
          _i5.OAuthSettings? oAuthSettings,
          _i6.Client? client,
          _i7.CredentialsRefreshedCallback? onCredentialsRefreshed) =>
      (super.noSuchMethod(
          Invocation.method(
              #execute, [oAuthSettings, client, onCredentialsRefreshed]),
          Future.value(_FakeClient())) as _i4.Future<_i2.Client>);
}
