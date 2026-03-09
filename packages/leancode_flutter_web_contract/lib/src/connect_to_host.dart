import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'result.dart';

/// Whether the current window is running inside an iframe.
bool isInIframe() => !identical(web.window.parent, web.window);

/// JS binding for the `__contract__connectToHost` function defined in
/// `connect_to_host.mjs` and loaded in the Flutter iframe app.
@JS('__contract__connectToHost')
external JSPromise<JSConnectToHostResult> jsConnectToHost(JSObject methods);

/// Raw JS result returned by [jsConnectToHost].
extension type JSConnectToHostResult._(JSObject _) implements JSObject {
  /// Connection status string (`"connected"` or an error indicator).
  external JSString get status;

  /// The host-provided methods object, present when connected.
  external JSObject? get host;

  /// A function that tears down the connection.
  external JSFunction? get destroy;

  /// Error details, present when the connection failed.
  external JSObject? get error;
}

/// Parses a raw [JSConnectToHostResult] into a typed
/// [RawConnectToHostResult].
RawConnectToHostResult<TJSHostMethods>
    parseConnectToHostResult<TJSHostMethods extends JSObject>(
  JSConnectToHostResult result,
) {
  final status = result.status.toDart;
  if (status == 'connected') {
    final host = result.host! as TJSHostMethods;
    final destroy = result.destroy!;
    return RawConnectToHostResultConnected<TJSHostMethods>(
      host,
      destroy,
    );
  }
  return RawConnectToHostResultError<TJSHostMethods>(
    result.error ?? 'Unknown error',
    result.destroy!,
  );
}

RawConnectToHostResultConnected<JSObject>? _cachedConnection;

/// Connects to the host page by calling the JS `__contract__connectToHost`
/// binding. Must only be called once; subsequent calls throw a [StateError].
Future<RawConnectToHostResult<TJSHostMethods>>
    connectToHostRaw<TJSHostMethods extends JSObject>(JSObject methods) async {
  final cached = _cachedConnection;
  if (cached != null) {
    throw StateError(
      'connectToHostRaw was called multiple times. '
      'Connect to the host only once (e.g. in main or a single initialization point).',
    );
  }

  final raw = await jsConnectToHost(methods).toDart;
  final result = parseConnectToHostResult<TJSHostMethods>(raw);

  if (result is RawConnectToHostResultConnected<TJSHostMethods>) {
    final connection = RawConnectToHostResultConnected<TJSHostMethods>(
      result.host,
      result.destroy,
    );

    _cachedConnection = connection;
    return connection;
  }
  return result;
}

/// Tears down the active host connection, if any.
void disconnectHost() {
  final cached = _cachedConnection;
  if (cached != null) {
    _cachedConnection = null;
    cached.destroy.callAsFunction();
  }
}
