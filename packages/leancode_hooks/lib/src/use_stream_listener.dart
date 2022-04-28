import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Listens to [stream] and calls [callback] on new data.
void useStreamListener<T>(
  Stream<T> stream,
  ValueChanged<T> callback, [
  List<Object?> keys = const [],
]) {
  useEffect(
    () {
      final subscription = stream.listen(callback);

      return subscription.cancel;
    },
    keys,
  );
}
