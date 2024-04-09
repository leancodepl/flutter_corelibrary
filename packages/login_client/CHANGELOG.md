# Unreleased

- Bump `leancode_lint` dev dependency to `12.0.0`.
- Bump `custom_lint` dev dependency to `0.6.4`.

# 3.1.0

- Add `credentials` getter to `LoginClient`. (#227)

# 3.0.0

- Bumped `http` dependency to `1.0.0`. (#105)
- **Breaking:** Bump minimum Dart version to 3.0. (#105)
- Mark the following as `abstract interface`: `CredentialsStorage` and `AuthorizationStrategy`. (#107)
  - To migrate simply implement them rather than extend.

# 2.1.0+2

- Fix accidentally removed codecov badge from README.

# 2.1.0+1

- Fix build badge in README.

# 2.1.0

- Bumped `build_runner` dependency to `2.0.0`

# 2.0.4

- `onCredentialsChanged` now yields **after** the credentials have changed (in the storage).

# 2.0.3

- Try refreshing the token on `401 Unauthorized` response

# 2.0.2

- Fix closing default HTTP client after logging out.

# 2.0.1

- Downgrade `meta` dependency from `1.4.0` to `1.3.0`.

# 2.0.0

- **Breaking:** Migrate to null-safety.
- **Breaking:** Bump minimum Dart version to 2.12.
- **Breaking**: Remove deprecated `credentialsChangedCallback` parameter from `LoginClient` constructor.

# 1.1.2

- Try refreshing the token on `401 Unauthorized` response

# 1.1.1

- Fix closing default HTTP client after logging out.

# 1.1.0

- OAuth2 `clientId` is now required.
- OAuth2 `clientSecret` now defaults to an empty string.
- Export `oauth2` `Credentials`, `AuthorizationException` and `ExpirationException`.
- Add `onCredentialsChanged` stream to `LoginClient`.
- Deprecate `credentialsChangedCallback`.

# 1.0.0+1

- Refresh pub listing.

# 1.0.0

- Complete rewrite of a library with **breaking changes**.
- Replaced `ApiConsts` with refreshed `OAuthSettings`.
- Simplified error handling to reuse OAuth2's `AuthorizationException` or this library's `RefreshException`.
- Started using official `oauth2` package instead of a unsupported fork.
- Removed `AssertionStrategy`. Use `CustomGrantStrategy` instead.

# 0.6.0

- Refactor login behavior
- Extract grant details to AuthStrategy implementations

# 0.5.0

- Upgrade packages

# 0.4.3

- Include expiration field in token model

# 0.4.2

- Add assertion and sms token authentication

# 0.4.1

- Export models

# 0.4.0

- Reimplement authentication
- `leancode_login_manager` has been replaced with `leancode_login_client`.
  Right now it only supports logging in with credentials.

# 0.3.4

- Fix: Base login manager - initialize client from http library when there is no token.

# 0.3.3

- Fix: Export login result enum

# 0.3.2

- Fix: Add rxdart and flutter_test dependencies

# 0.3.1

- Fix: now grant handlers use client from their login manager instance
- Tests: added simple result tests

# 0.3.0

- Breaking change: Grant handlers now return LoginResult instances instead of simple boolean value.
- Fix: isLoggedIn value was null when error was added into the stream. Now errors never happen there and unhandled exceptions are being rethrown.

# 0.2.4

- Fix: handle only unauthrized requests

# 0.2.3

- Fix: handling requests during token refresh

# 0.2.2

- Fix: regression with logout on every request

# 0.2.1

_DO NOT USE THIS VERSION, IT HAS A SEVERE REGRESSION_

- Fix: wrongly released mutex on multiple refresh requests

# 0.2.0

- Initial release
