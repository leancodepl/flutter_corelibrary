<div align="center">

[![Banner][banner-img]][leancode-landing]

</div>

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
  const AllFlowers({required this.page});

  final int page;

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
  const AddFlower({
    required this.name,
    required this.pretty,
  });

  final String name;
  final bool pretty;

  @override
  String getFullName() => 'AddFlower';

  @override
  Map<String, dynamic> toJson() => {'Name': name, 'Pretty': pretty};
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
final flowers = await cqrs.get(AllFlowers(page: 1));

// Run a command called add flower which... adds a pretty Daisy.
final result = await cqrs.run(AddFlower(name: 'Daisy', pretty: true));

// You can check the command result for its status, whether it successfully ran.
if (result case CommandSuccess()) {
  print('Added a daisy successfully!');
} else if (result case CommandFailure(isInvalid: true, :final validationErrors)) {
  print('Validation errors occured!');
  handleValidationErrors(validationErrors);
} else {
  print('Error occured');
}
```

---

## 🛠️ Maintained by LeanCode
<div align="center">

  [<img src="https://leancodepublic.blob.core.windows.net/public/wide.png" alt="LeanCode Logo" height="100" />][leancode-landing]

</div>

This package is built with 💙 by **[LeanCode][leancode-landing]**.
We are **top-tier experts** focused on Flutter Enterprise solutions.

### Why LeanCode?

- **Creators of [Patrol][patrol-landing]** – the next-gen testing framework for Flutter.

- **Production-Ready** – We use this package in apps with millions of users.
- **Full-Cycle Product Development** – We take your product from scratch to long-term maintenance.

<div align="center">
  <br />

  **Need help with your Flutter project?**

  [**👉 Hire our team**][leancode-estimate]
  &nbsp;&nbsp;•&nbsp;&nbsp;
  [Check our other packages][leancode-packages]

</div>

[pub-badge]: https://img.shields.io/pub/v/cqrs
[pub-badge-link]: https://pub.dev/packages/cqrs
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/cqrs-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/cqrs-test.yml
[codecov-badge]: https://img.shields.io/codecov/c/gh/leancodepl/flutter_corelibrary?flag=cqrs
[codecov-badge-link]: https://codecov.io/gh/leancodepl/flutter_corelibrary
[banner-img]: https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/cqrs/docs/imgs/banner.png
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=cqrs
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=cqrs
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=cqrs