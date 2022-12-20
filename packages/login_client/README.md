# login_client

[![login_client pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]
[![][codecov-badge]][codecov-badge-link]

OAuth2 compliant login client that:

- stores credentials for the currently authenticated user,
- automatically refreshes tokens,
- is easily pluggable into existing codebases.

## Usage

```dart
final loginClient = LoginClient(
  oAuthSettings: OAuthSettings(
    authorizationUri: apiUri.resolve('/auth'),
    clientId: 'pl.leancode.sample_app',
  ),
  credentialsStorage: const FlutterSecureCredentialsStorage(),
);

await loginClient.logIn(
  //                                       my secret pwd
  ResourceOwnerPasswordStrategy('Albert221', 'ny4ncat'),
);

final response = await loginClient.get('/secret-stuff');
```

## Flutter

For Flutter implementation of the `CredentialsStorage`, check out [`login_client_flutter`][login_client_flutter].

[pub-badge]: https://img.shields.io/pub/v/login_client
[pub-badge-link]: https://pub.dev/packages/login_client
[build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/login_client%20test
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22login_client+test%22
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/login_client-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/login_client-test.yml
[snippet]: assets/snippet.png
[login_client_flutter]: https://pub.dev/packages/login_client_flutter
