import 'dart:js_interop';

/// Result of a raw (JS-level) host connection attempt.
sealed class RawConnectToHostResult<TJSHostMethods extends JSObject> {
  /// Creates a [RawConnectToHostResult] with the given [destroy] callback.
  const RawConnectToHostResult(this.destroy);

  /// Tears down the connection and releases resources.
  final JSFunction destroy;
}

/// A successful raw connection carrying the JS [host] proxy.
class RawConnectToHostResultConnected<TJSHostMethods extends JSObject>
    extends RawConnectToHostResult<TJSHostMethods> {
  /// Creates a connected result with the JS [host] proxy and [destroy] callback.
  const RawConnectToHostResultConnected(this.host, super.destroy);

  /// The JS interop proxy exposing the host methods.
  final TJSHostMethods host;
}

/// A failed raw connection carrying the [error].
class RawConnectToHostResultError<TJSHostMethods extends JSObject>
    extends RawConnectToHostResult<TJSHostMethods> {
  /// Creates an error result with the given [error] and [destroy] callback.
  const RawConnectToHostResultError(this.error, super.destroy);

  /// The error that occurred during connection.
  final Object error;
}

/// Result of a typed host connection attempt.
sealed class ConnectToHostResult<THostMethods> {
  /// Creates a [ConnectToHostResult] with the given [destroy] callback.
  const ConnectToHostResult(this.destroy);

  /// Tears down the connection and releases resources.
  final void Function() destroy;
}

/// A successful typed connection carrying the [host] methods.
class ConnectToHostResultConnected<THostMethods>
    extends ConnectToHostResult<THostMethods> {
  /// Creates a connected result with the typed [host] and [destroy] callback.
  const ConnectToHostResultConnected(this.host, super.destroy);

  /// The typed host methods proxy.
  final THostMethods host;
}

/// A failed typed connection carrying the [error].
class ConnectToHostResultError<THostMethods>
    extends ConnectToHostResult<THostMethods> {
  /// Creates an error result with the given [error] and [destroy] callback.
  const ConnectToHostResultError(this.error, super.destroy);

  /// The error that occurred during connection.
  final Object error;
}
