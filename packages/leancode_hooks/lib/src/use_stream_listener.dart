import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Listens to [stream] and calls [onData] on new data.
///
/// See also:
///
/// * [Stream.listen] for information about [onError], [onDone], and
///   [cancelOnError].
void useStreamListener<T>(
  Stream<T> stream,
  ValueChanged<T> onData, {
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
  List<Object?> keys = const [],
}) {
  useEffect(
    () {
      final subscription = stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

      return subscription.cancel;
    },
    keys,
  );
}
