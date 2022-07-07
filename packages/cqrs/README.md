# cqrs

[![cqrs pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]
[![][codecov-badge]][codecov-badge-link]

A library for convenient communication with CQRS-compatible backends, using queries and commands.

## Usage example

```dart
import 'package:cqrs/cqrs.dart';

// You may use json_serializable for cutting on boilerplate code for your queries...
class AllFlowers implements Query<List<Flower>> {
  int page;

  @override
  String getFullName() => 'AllFlowers';

  @override
  List<Flower> resultFactory(dynamic json) {
    return List<Flower>.of(json as List).map(Flower.fromJson).toList();
  }

  @override
  Map<String, dynamic> toJson() => {'page': page};
}

// ...as well as commands.
class AddFlower implements Command {
  String name;
  bool pretty;

  @override
  String getFullName() => 'AddFlower';

  @override
  Map<String, dynamic> toJson() => {'Name': name, 'Pretty': pretty};
}

abstract class AddFlowerErrorCodes {
  static const alreadyExists = 1;
}

// Firstly you need an Uri to which the requests will be sent.
// Remember about the trailing slash as otherwise resolved paths
// may be invalid.
final apiUri = Uri.parse('https://flowers.garden/api/');

// Then construct a CQRS instance using the just created Uri
// and an HTTP client which in most cases will be probably handling
// refreshment of the tokens and their rotation.
final cqrs = Cqrs(loginClient, apiUri);

// Fetch first page of the all flowers query from the CQRS server.
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

[pub-badge]: https://img.shields.io/pub/v/cqrs
[pub-badge-link]: https://pub.dev/packages/cqrs
[build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/cqrs%20test
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22cqrs+test%22
[codecov-badge]: https://img.shields.io/codecov/c/gh/leancodepl/flutter_corelibrary?flag=cqrs
[codecov-badge-link]: https://codecov.io/gh/leancodepl/flutter_corelibrary
