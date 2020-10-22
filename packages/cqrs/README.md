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
// refreshment of the tokens and their rotation. It could be either
// and oauth2 client or a login_client library client.
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

## Contracts

_Contracts_ are classes and interfaces describing (mainly but not only) [queries and commands](https://en.wikipedia.org/wiki/Command%E2%80%93query_separation). They are usually written in C# and are transpiled to the Dart code using a custom code generation tool.

They describe data structures coming to and from the CQRS server and usually expose data transportation objects. Those are the objects being sent by the cqrs library with `get` in case of _queries_ and `run` in case of _commands_.

### Code generation

https://www.nuget.org/packages/LeanCode.ContractsGenerator/ - code generation tool for easy contracts transpilation from C# to Dart and TypeScript.

There is a helpful library to be imported right in the contracts. It contains few of the base interfaces used for queries and commands.

```dart
import 'package:cqrs/contracts.dart';
```

You might want to add it to your `contracts-config.json` preamble.

```json
[
    {
        "Dart": {
            "ContractsPreambleLines": [
                "import 'package:cqrs/contracts.dart';"
            ]
        }
    }
]
```


[cqrs-pub-badge]: https://img.shields.io/pub/v/cqrs
[cqrs-pub-badge-link]: https://pub.dev/packages/cqrs
[cqrs-build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/cqrs%2520test
[cqrs-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22cqrs+test%22
