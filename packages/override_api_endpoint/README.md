# override_api_endpoint

[![override_api_endpoint pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]
[![][codecov-badge]][codecov-badge-link]

Overrides and persists default API endpoint for the test environment.

## Usage

```dart
final apiEndpoint = await overrideApiEndpoint(
  'override',
  'apiAddress',
  Uri.parse('https://api.example.com/'),
);
```
[pub-badge]: https://img.shields.io/pub/v/override_api_endpoint
[pub-badge-link]: https://pub.dev/packages/override_api_endpoint
[build-badge]: https://img.shields.io/github/workflow/status/leancodepl/flutter_corelibrary/override_api_endpoint%20test
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions?query=workflow%3A%22override_api_endpoint+test%22
[codecov-badge]: https://img.shields.io/codecov/c/gh/leancodepl/flutter_corelibrary?flag=override_api_endpoint
[codecov-badge-link]: https://codecov.io/gh/leancodepl/flutter_corelibrary
[override_api_endpoint_flutter]: https://pub.dev/packages/override_api_endpoint_flutter
