import 'package:bloc/bloc.dart';
import 'package:pub_semver/pub_semver.dart';

import 'connect_to_host.dart';
import 'connect_to_host_state.dart';
import 'result.dart';
import 'url_params.dart';

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
  )   : _options = options,
        super(ConnectToHostIdle<THostMethods>()) {
    _connect();
  }

  final ConnectToHostCubitOptions<TRemoteMethods, THostMethods> _options;
  void Function()? _destroy;

  Future<void> _connect() async {
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
        ConnectToHostIncompatible<THostMethods>(
          hostVersion,
          _options.contractVersion,
        ),
      );
      return;
    }
    if (!range.allows(hostVer)) {
      emit(
        ConnectToHostIncompatible<THostMethods>(
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
            emit(ConnectToHostConnected<THostMethods>(host));
          case ConnectToHostResultError(:final error):
            emit(ConnectToHostError<THostMethods>(error));
        }
      }
    } catch (err, _) {
      if (!isClosed) {
        emit(ConnectToHostError<THostMethods>(err));
      }
    }
  }

  @override
  Future<void> close() {
    _destroy?.call();
    return super.close();
  }
}
