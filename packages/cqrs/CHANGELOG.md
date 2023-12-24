# Unreleased

- Bump `leancode_lint` dev dependency to `8.0.0`. (#230)

# 10.0.1

- **Breaking:** Rename `forbiddenAccess` to `authorization` in error enums.
- Update error enums docs.
- Fix `CqrsMiddleware` not being exported from the package.
- Move `hasError` and `hasErrorForProperty` from `CommandResponse` to `CommandFailure`.

# 10.0.0

**Retracted.**

- **Breaking:** Fundamentaly change overall `Cqrs` API making it no-throw guarantee.
- **Breaking:** Make `Cqrs.get`, `Cqrs.run` and `Cqrs.perform` return result data in form of `QueryResult`, `CommandResult` and `OperationResult` respectively.
- Add `logger` parameter (of type `Logger` from `logging` package) to `Cqrs` default constructor. If provided, the `logger` will be used as a debug logging interface in execution of CQRS methods.
- Add middleware mechanism in form of `CqrsMiddleware` intended to use in processing result from queries, commands and operations.
- **Breaking:** Remove `CqrsException`.
- **Breaking:** Rename previous `CommandResult` to `CommandResponse` and make it package private.
- **Breaking:** Mark the `CqrsMethod` as `sealed`.
- Make `ValidationError` extend `Equatable` from `equatable` package.
- Add `equatable` (`^2.0.5`) and `logging` (`^1.2.0`) dependencies.

# 9.0.0

- Bumped `http` dependency to `1.0.0`. (#105)
- **Breaking:** Bump minimum Dart version to 3.0. (#105)
- Mark the following as `abstract interface`: `CqrsMethod`, `Query`, `Command`, `Operation`. (#107)
  - To migrate simply implement them rather than extending.

# 8.0.0+1

- Fix build badge in README.

# 8.0.0

- **Breaking:** Bump minimum Dart version to 2.17.

# 7.0.0

- **Breaking:** Rename `CQRS` and similar to `Cqrs` per [_Effective Dart_](https://dart.dev/guides/language/effective-dart/style#do-capitalize-acronyms-and-abbreviations-longer-than-two-letters-like-words).
- **Breaking:** Remove `IRemoteQuery` and `IRemoteCommand`. Use their equivalents `Query` and `Command` respectively.
- Add new transport type `Operation` which is a `Query` with side effects of a `Command`.

# 6.2.1

- Add human-readable `toString` method for `CommandResult`.

# 6.2.0

- Export `CommandResult` from `/contracts.dart`.

# 6.1.0

- `CommandResult` and `ValidationError` now implement the `toJson()` method.

# 6.0.0

- Stable null-safe release.
- **Breaking:** Bump minimum Dart version to 2.12.

# 5.0.0

- Revert to 4.1.1
- **Breaking:** Add `propertyName` field in `ValidationError`.
- **Breaking:** Remove deprecated `success` parameter from `CommandResult` constructor.

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
