# leancode_flutter_web_contract

A Flutter web package for bidirectional RPC between a Flutter app running in an iframe and its parent host page. It uses [Penpal](https://github.com/nicknisi/penpal) under the hood to exchange method calls over `postMessage`, with built-in semver-based contract versioning.

## Features

- Bidirectional method calls between iframe (Flutter) and host page
- Semver-based contract version negotiation
- Ready-to-use `ConnectToHostCubit` for managing the connection lifecycle
- Type-safe Dart wrappers over the JS interop layer

## Setup

### 1. Install the package

```yaml
dependencies:
  leancode_flutter_web_contract: ^0.0.1
```

### 2. Load the JS asset

Add the bundled script to your Flutter web app's `web/index.html` **before** the Flutter bootstrap script:

```html
<script src="assets/packages/leancode_flutter_web_contract/assets/connect_to_host.js"></script>
```

### 3. Host page setup

The host page must use Penpal's `connectToChild` (or the equivalent `WindowMessenger` + `connect`) to communicate with the iframe. It should pass the contract version as a URL query parameter:

```
https://your-flutter-app.com/?contractVersion=1.0.0
```

For the host (parent) side, the [`@leancodepl/iframe-contract`](https://github.com/leancodepl/js_corelibrary/tree/main/packages/iframe-contract) package provides type-safe contracts with React hooks, contract version negotiation, and URL parameter handling out of the box. See the [example](https://github.com/leancodepl/js_corelibrary/tree/main/packages/iframe-contract/example) for a complete host + remote setup.

## Usage

### Define the JS interop types

Create extension types for the methods exposed by each side:

```dart
import 'dart:js_interop';

// Methods the host exposes to the Flutter iframe
extension type JSHostMethods._(JSObject _) implements JSObject {
  external JSPromise<JSString> getAuthToken();
  external void navigateTo(JSString route);
}

// Methods the Flutter iframe exposes to the host
extension type JSRemoteMethods._(JSObject _) implements JSObject {
  external void onThemeChanged(JSString theme);
}
```

### Using `ConnectToHostCubit`

The easiest way to manage the connection lifecycle is via `ConnectToHostCubit`:

```dart
import 'package:leancode_flutter_web_contract/leancode_flutter_web_contract.dart';

class HostMethods {
  HostMethods(this._js);

  final JSHostMethods _js;

  Future<String> getAuthToken() async {
    final result = await _js.getAuthToken().toDart;
    return result.toDart;
  }

  void navigateTo(String route) => _js.navigateTo(route.toJS);
}

final cubit = ConnectToHostCubit(
  ConnectToHostCubitOptions(
    methods: JSRemoteMethods(
      // provide the methods the host can call
    ),
    connect: (methods) async {
      final raw = await connectToHostRaw<JSHostMethods>(methods);
      return raw.toTyped(HostMethods.new);
    },
    contractVersion: '1.0.0',
    contractVersionRange: '>=1.0.0 <2.0.0',
  ),
);
```

Then react to connection states:

```dart
BlocBuilder<ConnectToHostCubit<JSRemoteMethods, HostMethods>,
    ConnectToHostState<HostMethods>>(
  bloc: cubit,
  builder: (context, state) => switch (state) {
    ConnectToHostIdle() => const CircularProgressIndicator(),
    ConnectToHostConnected(:final host) => MyApp(hostMethods: host),
    ConnectToHostIncompatible(:final hostVersion, :final remoteVersion) =>
      Text('Version mismatch: host $hostVersion vs remote $remoteVersion'),
    ConnectToHostError(:final error) => Text('Error: $error'),
  },
);
```

### Using the raw API

For more control, use `connectToHostRaw` directly:

```dart
if (isInIframe()) {
  final result = await connectToHostRaw<JSHostMethods>(myMethods);

  switch (result) {
    case RawConnectToHostResultConnected(:final host):
      // use host methods
      break;
    case RawConnectToHostResultError(:final error):
      // handle error
      break;
  }
}
```

> **Note:** `connectToHostRaw` must only be called once. Subsequent calls throw a `StateError`. Call `disconnectHost()` to tear down the connection.

## Contract versioning

The host page passes a `contractVersion` query parameter in the iframe URL. `ConnectToHostCubit` reads it and checks it against the `contractVersionRange` you provide (parsed as a semver `VersionConstraint`). If the versions are incompatible, the cubit emits `ConnectToHostIncompatible` instead of attempting to connect.

## API overview

| Symbol | Description |
|--------|-------------|
| `isInIframe()` | Whether the current window is inside an iframe |
| `connectToHostRaw()` | Establishes a raw JS-level connection to the host |
| `disconnectHost()` | Tears down the active connection |
| `parseConnectToHostResult()` | Parses the raw JS result into a typed result |
| `ConnectToHostCubit` | Cubit managing the full connection lifecycle |
| `ConnectToHostCubitOptions` | Configuration for `ConnectToHostCubit` |
| `ConnectToHostState` | Sealed class with `Idle`, `Connected`, `Incompatible`, `Error` states |
| `UrlParamsBase` | Reads URL query parameters (e.g. `contractVersion`) |

## Building the JS asset

The TypeScript source lives in `js/`. To rebuild the bundled JS asset:

```bash
cd js
npm install
npx vite build
```

The output is written to `assets/connect_to_host.js`.
