<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-debug-page" align="center">
  <img alt="leancode_debug_page" src="https://github.com/user-attachments/assets/708277fe-a75e-430f-8c03-4288ffdb1678" />
</a>

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

<p style="text-align: center;">
   <a href="https://leancode.co/?utm_source=readme&utm_medium=leancode_debug_page_package">
      <img alt="LeanCode" src="https://leancodepublic.blob.core.windows.net/public/wide.png" width="300"/>
   </a>
   <p style="text-align: center;">
   Built with ☕️ by <a href="https://leancode.co/?utm_source=readme&utm_medium=leancode_debug_page_package">LeanCode</a>
   </p>
</p>

[pub-badge]: https://img.shields.io/pub/v/leancode_debug_page
[pub-badge-link]: https://pub.dev/packages/leancode_debug_page
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_debug_page-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_debug_page-test.yml
