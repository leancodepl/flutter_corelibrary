/// Base state for the host connection lifecycle.
sealed class ConnectToHostState<THostMethods> {
  const ConnectToHostState();
}

/// Initial idle state before any connection attempt.
class ConnectToHostIdle<THostMethods> extends ConnectToHostState<THostMethods> {
  /// Creates an idle state.
  const ConnectToHostIdle();
}

/// Successfully connected to the host.
class ConnectToHostConnected<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates a connected state with the given [host] methods.
  const ConnectToHostConnected(this.host);

  /// The host methods available after a successful connection.
  final THostMethods host;
}

/// The host and remote contract versions are incompatible.
class ConnectToHostIncompatible<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates an incompatible state with the mismatched versions.
  const ConnectToHostIncompatible(this.hostVersion, this.remoteVersion);

  /// The version reported by the host.
  final String hostVersion;

  /// The version expected by the remote.
  final String remoteVersion;
}

/// An error occurred while connecting to the host.
class ConnectToHostError<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates an error state with the given [error].
  const ConnectToHostError(this.error);

  /// The error that occurred during the connection attempt.
  final Object error;
}
