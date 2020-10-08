# dart_cqrs

## Introduction

`cqrs` is a simple CQRS client (with http) using helper Command/Query classes.

## Code Samples

Queries:

```dart
const result = await _cqrs.get(SimpleQuery());
print result;
```

Commands:

```dart
const result = await _cqrs.run(SimpleCommand());

if (result.wasSuccessful) {
  print('Success!');
}
```
