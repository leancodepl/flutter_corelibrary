# login_client

[![login_client pub.dev badge][login_client-pub-badge]][login_client-pub-badge-link]
[![][login_client-build-badge]][login_client-build-badge-link]

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

[login_client-pub-badge]: https://img.shields.io/pub/v/login_client
[login_client-pub-badge-link]: https://pub.dev/packages/login_client
[login_client-build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/login_client%2520test
[login_client-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22login_client+test%22
[snippet]: assets/snippet.png
[login_client_flutter]: https://pub.dev/packages/login_client_flutter
