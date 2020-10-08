# Changelog

## [3.0.2] - 2020-07-27

- Add possibility to add custom headers

## [3.0.1] - 2020-05-11

- Fix the returned null value directly from query

## [3.0.0] - 2020-04-10
### Breaking changes

- Remove deprecated @virtual annotations
- Rename `toJsonMap` to `toJson`
- Fix readme

## [2.0.1+1] - 2019-02-07

- Update readme

## [2.0.1] - 2019-02-07

### Fixed

- Fix validation errors

## [2.0.0] - 2019-02-06

### Breaking changes

- Remove normalizeDate function
- Add @virtual annotations

## [1.0.6] - 2019-01-31

### Fixed

- From now `CQRSException` implements `Exception`

## [1.0.5] - 2018-12-31

### Fixed

- Overload `toString()` on `CQRSException` in case of treating it like `dynamic`

## [1.0.4] - 2018-12-31

### Fixed

- Fix command result JSON validation.

## [1.0.3] - 2018-12-31

### Fixed

- Query `resultFactory` only argument `decodedJson` is now of `dynamic` type. It's due to a fact, that it can be more than a map, i.e. an array of maps.

## [1.0.2] - 2018-12-31

### Fixed

- Removed useless oauth dependency. Now this package depends only on http.
