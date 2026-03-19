import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:leancode_flutter_cyberware_contract_base/src/connect_to_host.dart';
import 'package:leancode_flutter_cyberware_contract_base/src/result.dart';
import 'package:leancode_flutter_cyberware_contract_base/src/url_params.dart';
import 'package:pub_semver/pub_semver.dart';

/// Configuration options for [ConnectToHostCubit].
class ConnectToHostCubitOptions<TRemoteMethods, THostMethods> {
  /// Creates options for [ConnectToHostCubit].
  const ConnectToHostCubitOptions({
    required this.connect,
    required this.contractVersion,
    required this.contractVersionRange,
  });

  /// A function that establishes the connection and returns the host methods.
  final Future<ConnectToHostResult<THostMethods>> Function() connect;

  /// The contract version implemented by remote.
  final String contractVersion;

  /// A semver range of host contract versions this remote is compatible with.
  final String contractVersionRange;
}

/// A [Cubit] that manages the lifecycle of connecting to a host application
/// from within an iframe.
class ConnectToHostCubit<TRemoteMethods, THostMethods>
    extends Cubit<ConnectToHostState<THostMethods>> {
  /// Creates a [ConnectToHostCubit] and immediately attempts to connect.
  ConnectToHostCubit(
    ConnectToHostCubitOptions<TRemoteMethods, THostMethods> options,
  ) : _options = options,
      super(ConnectToHostStateIdle<THostMethods>());

  final ConnectToHostCubitOptions<TRemoteMethods, THostMethods> _options;
  void Function()? _destroy;

  /// Attempts to connect to the host application.
  ///
  /// Does nothing if the app is not running inside an iframe or if the host
  /// contract version is missing or incompatible.
  Future<void> connect() async {
    if (!isInIframe()) {
      return;
    }

    final hostVersion = UrlParamsBase.contractVersion;
    if (hostVersion == null || hostVersion.isEmpty) {
      return;
    }

    final range = VersionConstraint.parse(_options.contractVersionRange);
    Version hostVer;
    try {
      hostVer = Version.parse(hostVersion);
    } catch (_) {
      emit(
        ConnectToHostStateIncompatible<THostMethods>(
          hostVersion,
          _options.contractVersion,
        ),
      );
      return;
    }
    if (!range.allows(hostVer)) {
      emit(
        ConnectToHostStateIncompatible<THostMethods>(
          hostVersion,
          _options.contractVersion,
        ),
      );
      return;
    }

    try {
      final result = await _options.connect();

      if (!isClosed) {
        _destroy = result.destroy;

        switch (result) {
          case ConnectToHostResultConnected(:final host):
            emit(ConnectToHostStateConnected<THostMethods>(host));
          case ConnectToHostResultError(:final error):
            emit(ConnectToHostStateError<THostMethods>(error));
        }
      }
    } catch (err, _) {
      if (!isClosed) {
        emit(ConnectToHostStateError<THostMethods>(err));
      }
    }
  }

  @override
  Future<void> close() {
    _destroy?.call();
    return super.close();
  }
}

/// Base state for the host connection lifecycle.
sealed class ConnectToHostState<THostMethods> with EquatableMixin {
  ConnectToHostState();
}

/// Initial idle state before any connection attempt.
class ConnectToHostStateIdle<THostMethods> extends ConnectToHostState<THostMethods> {
  /// Creates an idle state.
  ConnectToHostStateIdle();

  @override
  List<Object?> get props => [];
}

/// Successfully connected to the host.
class ConnectToHostStateConnected<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates a connected state with the given [host] methods.
  ConnectToHostStateConnected(this.host);

  /// The host methods available after a successful connection.
  final THostMethods host;

  @override
  List<Object?> get props => [host];
}

/// The host and remote contract versions are incompatible.
class ConnectToHostStateIncompatible<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates an incompatible state with the mismatched versions.
  ConnectToHostStateIncompatible(this.hostVersion, this.remoteVersion);

  /// The version reported by the host.
  final String hostVersion;

  /// The version expected by the remote.
  final String remoteVersion;

  @override
  List<Object?> get props => [hostVersion, remoteVersion];
}

/// An error occurred while connecting to the host.
class ConnectToHostStateError<THostMethods>
    extends ConnectToHostState<THostMethods> {
  /// Creates an error state with the given [error].
  ConnectToHostStateError(this.error);

  /// The error that occurred during the connection attempt.
  final Object error;

  @override
  List<Object?> get props => [error];
}
