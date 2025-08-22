# Unreleased

# 3.1.0

- Add configurable `FlutterSecureStorage` support to `FlutterSecureCredentialsStorage`. The constructor now accepts an optional `storage` parameter, allowing users to provide a custom `FlutterSecureStorage` instance with platform-specific configuration options (e.g., iOS KeyChain accessibility settings).
- Bump `leancode_lint` dev dependency to `12.0.0`.
- Bump `custom_lint` dev dependency to `0.6.4`.

# 3.0.0

- Bump `flutter` version range to `>=3.10.0`.
- Bump `login_client` dependency to `3.0.0`.
- Bump `leancode_lint` dev dependency to `8.0.0`. (#230)

# 2.0.1+1

- Fix build badge in README.

# 2.0.1

- Increase `flutter_secure_storage` version range to `>=4.2.0 <6.0.0`.

# 2.0.0

- **Breaking:** Migrate to null-safety.
- **Breaking:** Bump minimum Dart version to 2.12.
- **Breaking:** Bump minimum Flutter version to 2.0.

# 1.0.1

- Fix reading null credentials.

# 1.0.0

- First release.
