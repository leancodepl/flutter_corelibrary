// Mocks generated by Mockito 5.0.0 from annotations
// in login_client/test/login_client_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i8;
import 'dart:convert' as _i13;
import 'dart:typed_data' as _i6;

import 'package:http/src/base_request.dart' as _i12;
import 'package:http/src/client.dart' as _i10;
import 'package:http/src/response.dart' as _i5;
import 'package:http/src/streamed_response.dart' as _i4;
import 'package:login_client/src/credentials_storage/credentials_storage.dart'
    as _i11;
import 'package:login_client/src/oauth_settings.dart' as _i9;
import 'package:login_client/src/strategies/authorization_strategy.dart' as _i7;
import 'package:mockito/mockito.dart' as _i1;
import 'package:oauth2/src/client.dart' as _i2;
import 'package:oauth2/src/credentials.dart' as _i3;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeClient extends _i1.Fake implements _i2.Client {}

class _FakeCredentials extends _i1.Fake implements _i3.Credentials {}

class _FakeStreamedResponse extends _i1.Fake implements _i4.StreamedResponse {}

class _FakeResponse extends _i1.Fake implements _i5.Response {}

class _FakeUint8List extends _i1.Fake implements _i6.Uint8List {}

/// A class which mocks [AuthorizationStrategy].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthorizationStrategy extends _i1.Mock
    implements _i7.AuthorizationStrategy {
  MockAuthorizationStrategy() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<_i2.Client> execute(
          _i9.OAuthSettings? oAuthSettings,
          _i10.Client? client,
          _i3.CredentialsRefreshedCallback? onCredentialsRefreshed) =>
      (super.noSuchMethod(
          Invocation.method(
              #execute, [oAuthSettings, client, onCredentialsRefreshed]),
          returnValue: Future.value(_FakeClient())) as _i8.Future<_i2.Client>);
}

/// A class which mocks [CredentialsStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockCredentialsStorage extends _i1.Mock
    implements _i11.CredentialsStorage {
  MockCredentialsStorage() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.Future<_i3.Credentials?> read() =>
      (super.noSuchMethod(Invocation.method(#read, []),
              returnValue: Future.value(_FakeCredentials()))
          as _i8.Future<_i3.Credentials?>);
  @override
  _i8.Future<void> save(_i3.Credentials? credentials) =>
      (super.noSuchMethod(Invocation.method(#save, [credentials]),
          returnValue: Future.value(null),
          returnValueForMissingStub: Future.value()) as _i8.Future<void>);
  @override
  _i8.Future<void> clear() => (super.noSuchMethod(Invocation.method(#clear, []),
      returnValue: Future.value(null),
      returnValueForMissingStub: Future.value()) as _i8.Future<void>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Credentials get credentials =>
      (super.noSuchMethod(Invocation.getter(#credentials),
          returnValue: _FakeCredentials()) as _i3.Credentials);
  @override
  _i8.Future<_i4.StreamedResponse> send(_i12.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]),
              returnValue: Future.value(_FakeStreamedResponse()))
          as _i8.Future<_i4.StreamedResponse>);
  @override
  _i8.Future<_i2.Client> refreshCredentials([List<String>? newScopes]) =>
      (super.noSuchMethod(Invocation.method(#refreshCredentials, [newScopes]),
          returnValue: Future.value(_FakeClient())) as _i8.Future<_i2.Client>);
  @override
  _i8.Future<_i5.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> post(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i13.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> put(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i13.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> patch(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i13.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<_i5.Response> delete(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i13.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future.value(_FakeResponse()))
          as _i8.Future<_i5.Response>);
  @override
  _i8.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}),
          returnValue: Future.value('')) as _i8.Future<String>);
  @override
  _i8.Future<_i6.Uint8List> readBytes(Uri? url,
          {Map<String, String>? headers}) =>
      (super.noSuchMethod(
              Invocation.method(#readBytes, [url], {#headers: headers}),
              returnValue: Future.value(_FakeUint8List()))
          as _i8.Future<_i6.Uint8List>);
}
