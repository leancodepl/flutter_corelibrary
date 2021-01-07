# 1.1.0

- OAuth2 `clientId` and `clientSecret` now default to an empty string.
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
