# 5.0.0-nullsafety.1

- Add `propertyName` field in `ValidationError`.

# 5.0.0-nullsafety.0

- **Breaking:** Migrate to null-safety.
- **Breaking:** Bump minimum Dart version to 2.12 prerelease.
- **Breaking:** Remove deprecated `success` parameter from `CommandResult` constructor.

# 4.1.1

- Fix exception thrown when the query result is `null`.

# 4.1.0

- Add `success` and `failed` constructors in `CommandResult`.
- Add `failed` getter in `CommandResult`.
- Make `success` field in `CommandResult` a getter. This is compatible with how [the backend works](https://github.com/leancodepl/corelibrary/blob/a3a2a27b20e1cf684fb88aa55958721eff19c2bc/src/Domain/LeanCode.CQRS/CommandResult.cs#L11).
- Deprecate `success` param in `CommandResult` constructor.

# 4.0.0+2

- Refresh pub listing.

# 4.0.0

- Complete rewrite of a library with **breaking changes**.
- Add `headers` parameter in `run` and `get` methods.
- Add `hasError` method in `CommandResult`.
- Pass HTTP client directly to `CQRS` constructor instead as a factory method.
- `package:cqrs/contracts.dart` utility library to use in contracts.

# 3.0.2

- Add possibility to add custom headers

# 3.0.1

- Fix the returned null value directly from query

# 3.0.0

- Remove deprecated @virtual annotations
- Rename `toJsonMap` to `toJson`
- Fix readme

# 2.0.1+1

- Update readme

# 2.0.1

- Fix validation errors

# 2.0.0

- Remove normalizeDate function
- Add @virtual annotations

# 1.0.6

- From now `CQRSException` implements `Exception`

# 1.0.5

- Overload `toString()` on `CQRSException` in case of treating it like `dynamic`

# 1.0.4

- Fix command result JSON validation.

# 1.0.3

- Query `resultFactory` only argument `decodedJson` is now of `dynamic` type. It's due to a fact, that it can be more than a map, i.e. an array of maps.

# 1.0.2

- Removed useless oauth dependency. Now this package depends only on http.
