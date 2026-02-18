<div align="center">

[![Banner][banner-img]][leancode-landing]

</div>

# leancode_debug_page

[![leancode_debug_page pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

A debug page that gathers HTTP requests and logger logs. Features:

- Detailed information about requests (request, response) and logs
- Filtering requests by
  - Status code
  - Search
- Filtering logs by
  - Log level
  - Search
- Sharing
  - All logs / requests
  - Individual items
- Two configurable entry points
  - Draggable floating action button
  - Device shake

#### Requests list

![Requests list](images/requests.png)

#### Request details

![Request details](images/request_details.png)

#### Logs list

![Logs list](images/logs.png)

## Usage

Wrap your `MaterialApp` with a `DebugPageOverlay` and provide a `DebugPageController`.
`DebugPageController` requires:

- a `LoggingHttpClient`, which is a wrapper over `Client` from Dart's `http` package.
  This allows you to use your own client implementations.

- a navigator key, which is used to navigate to the debug page.

***Make sure to pass the controller's `navigatorObserver` to your app widget.***

```dart
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  late DebugPageController _debugPageController;

  @override
  void initState() {
    super.initState();

    _debugPageController = DebugPageController(
      showEntryButton: true,
      loggingHttpClient: widget._loggingHttpClient,
      navigatorKey: navigatorKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DebugPageOverlay(
      controller: _debugPageController,
      child: MaterialApp(
        title: 'Debug Page Demo',
        navigatorKey: navigatorKey,
        navigatorObservers: [_debugPageController.navigatorObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(
          title: 'Flutter Debug Page Demo Page',
          loggingHttpClient: widget._loggingHttpClient,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debugPageController.dispose();

    super.dispose();
  }
}
```

For a complete working sample, see [example](example).

You can configure debug page's entry points by setting ```showEntryButton``` (defaults to false) and
```showOnShake``` (defaults to true) flags in the constructor of ```DebugPageController```.

## Warning

For gathering logs from loggers, this package relies on listening to `Logger.root`. This means that
changing `Logger.root.level` affects this package's behavior, and the logs are only collected from
the current isolate.

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

[pub-badge]: https://img.shields.io/pub/v/leancode_debug_page
[pub-badge-link]: https://pub.dev/packages/leancode_debug_page
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_debug_page-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_debug_page-test.yml
[banner-img]: https://raw.githubusercontent.com/leancodepl/flutter_corelibrary/refs/heads/master/packages/leancode_debug_page/images/banner.png
[leancode-landing]: https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-debug-page
[leancode-estimate]: https://leancode.co/get-estimate?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-debug-page
[leancode-packages]: https://pub.dev/packages?q=publisher%3Aleancode.co&sort=downloads
[patrol-landing]: https://patrol.leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-debug-page