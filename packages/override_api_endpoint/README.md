<div align="center">

[![Banner][banner-img]][leancode-landing]

</div>

# override_api_endpoint

[![override_api_endpoint pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

Overrides and persists default API endpoint for the test environment.

* `deeplinkOverrideSegment` - part of deeplink that uniquely
identifies deeplink that is used to override API endpoint
eg. `override` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
* `deeplinkQueryParameter` - query parameter of the override API
endpoint deeplink that contains url encoded API endpoint to be used
eg. `apiAddress` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
* `defaultEndpoint` - fallback URL that should be used if app does not
have any endpoint introduced via deeplink or if `deeplinkQueryParameter` is
not provided

## Usage

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

final apiEndpoint = await overrideApiEndpoint(
  sharedPreferences: await SharedPreferences.getInstance(),
  getInitialUri: getInitialUri,
  deeplinkOverrideSegment: 'override',
  deeplinkQueryParameter: 'apiAddress',
  defaultEndpoint: Uri.parse('https://api.example.com'),
);
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

[pub-badge]: https://img.shields.io/pub/v/override_api_endpoint
[pub-badge-link]: https://pub.dev/packages/override_api_endpoint
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/override_api_endpoint-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/override_api_endpoint-test.yml
[override_api_endpoint_flutter]: https://pub.dev/packages/override_api_endpoint_flutter
[banner-img]: https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/override_api_endpoint/docs/imgs/banner.png
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=override-api-endpoint
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=override-api-endpoint
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=override-api-endpoint