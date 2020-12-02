# 4.0.0+1

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
