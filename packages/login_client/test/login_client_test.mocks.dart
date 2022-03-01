// Mocks generated by Mockito 5.1.0 from annotations
// in login_client/test/login_client_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;
import 'dart:convert' as _i8;
import 'dart:typed_data' as _i9;

import 'package:http/http.dart' as _i3;
import 'package:login_client/src/credentials_storage/credentials_storage.dart'
    as _i7;
import 'package:login_client/src/oauth_settings.dart' as _i6;
import 'package:login_client/src/strategies/authorization_strategy.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:oauth2/oauth2.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeClient_0 extends _i1.Fake implements _i2.Client {}

class _FakeCredentials_1 extends _i1.Fake implements _i2.Credentials {}

class _FakeStreamedResponse_2 extends _i1.Fake implements _i3.StreamedResponse {
}

class _FakeResponse_3 extends _i1.Fake implements _i3.Response {}

class _FakeUri_4 extends _i1.Fake implements Uri {}

/// A class which mocks [AuthorizationStrategy].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthorizationStrategy extends _i1.Mock
    implements _i4.AuthorizationStrategy {
  MockAuthorizationStrategy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Client> execute(
          _i6.OAuthSettings? oAuthSettings,
          _i3.Client? client,
          _i2.CredentialsRefreshedCallback? onCredentialsRefreshed) =>
      (super.noSuchMethod(
              Invocation.method(
                  #execute, [oAuthSettings, client, onCredentialsRefreshed]),
              returnValue: Future<_i2.Client>.value(_FakeClient_0()))
          as _i5.Future<_i2.Client>);
}

/// A class which mocks [CredentialsStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockCredentialsStorage extends _i1.Mock
    implements _i7.CredentialsStorage {
  MockCredentialsStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Credentials?> read() =>
      (super.noSuchMethod(Invocation.method(#read, []),
              returnValue: Future<_i2.Credentials?>.value())
          as _i5.Future<_i2.Credentials?>);
  @override
  _i5.Future<void> save(_i2.Credentials? credentials) =>
      (super.noSuchMethod(Invocation.method(#save, [credentials]),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
  @override
  _i5.Future<void> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i5.Future<void>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Credentials get credentials =>
      (super.noSuchMethod(Invocation.getter(#credentials),
          returnValue: _FakeCredentials_1()) as _i2.Credentials);
  @override
  _i5.Future<_i3.StreamedResponse> send(_i3.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]),
              returnValue:
                  Future<_i3.StreamedResponse>.value(_FakeStreamedResponse_2()))
          as _i5.Future<_i3.StreamedResponse>);
  @override
  _i5.Future<_i2.Client> refreshCredentials([List<String>? newScopes]) =>
      (super.noSuchMethod(Invocation.method(#refreshCredentials, [newScopes]),
              returnValue: Future<_i2.Client>.value(_FakeClient_0()))
          as _i5.Future<_i2.Client>);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
  @override
  _i5.Future<_i3.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> post(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i8.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> put(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i8.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> patch(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i8.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<_i3.Response> delete(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i8.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i3.Response>.value(_FakeResponse_3()))
          as _i5.Future<_i3.Response>);
  @override
  _i5.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
  @override
  _i5.Future<_i9.Uint8List> readBytes(Uri? url,
          {Map<String, String>? headers}) =>
      (super.noSuchMethod(
              Invocation.method(#readBytes, [url], {#headers: headers}),
              returnValue: Future<_i9.Uint8List>.value(_i9.Uint8List(0)))
          as _i5.Future<_i9.Uint8List>);
}

/// A class which mocks [OAuthSettings].
///
/// See the documentation for Mockito's code generation for more information.
class MockOAuthSettings extends _i1.Mock implements _i6.OAuthSettings {
  MockOAuthSettings() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Uri get authorizationUri =>
      (super.noSuchMethod(Invocation.getter(#authorizationUri),
          returnValue: _FakeUri_4()) as Uri);
  @override
  String get clientId =>
      (super.noSuchMethod(Invocation.getter(#clientId), returnValue: '')
          as String);
  @override
  String get clientSecret =>
      (super.noSuchMethod(Invocation.getter(#clientSecret), returnValue: '')
          as String);
  @override
  List<String> get scopes =>
      (super.noSuchMethod(Invocation.getter(#scopes), returnValue: <String>[])
          as List<String>);
}
