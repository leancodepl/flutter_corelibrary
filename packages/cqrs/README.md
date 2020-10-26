# cqrs

[![cqrs pub.dev badge][cqrs-pub-badge]][cqrs-pub-badge-link]
[![][cqrs-build-badge]][cqrs-build-badge-link]

A library for convenient communication with CQRS-compatible backends, using queries and commands.

## Usage example

```dart
import 'package:cqrs/cqrs.dart';

// Import your generated contracts.
import 'contracts.dart';

// Firstly you need an Uri to which the requests will be sent.
// Remember about the trailing slash as otherwise resolved paths
// may be invalid.
final apiUri = Uri.parse('https://flowers.garden/api/');

// Then construct a CQRS instance using the just created Uri
// and an HTTP client which in most cases will be probably handling
// refreshment of the tokens and their rotation.
final cqrs = CQRS(loginClient, apiUri);

// Fetch first page of the all flowers query from the CQRS server.
// You can map the DTOs received to other objects or use it as-is.
final flowers = await cqrs.get(AllFlowers()..page = 1);

// Run a command called add flower which... adds a pretty Daisy.
final result = await cqrs.run(AddFlower()..name = 'Daisy'..pretty = true);

// You can check the command result for its status, whether it successfully ran.
if (result.success) {
  print('Added a daisy successfully!');
} else if (result.hasError(AddFlowerErrorCodes.alreadyExists)) {
  // Or check for errors in `result.errors`. You can use a `hasError` helper.
  print('Daisy already exists!');
} else {
  print('Error occured');
}
```

[cqrs-pub-badge]: https://img.shields.io/pub/v/cqrs
[cqrs-pub-badge-link]: https://pub.dev/packages/cqrs
[cqrs-build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/cqrs%2520test
[cqrs-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22cqrs+test%22
