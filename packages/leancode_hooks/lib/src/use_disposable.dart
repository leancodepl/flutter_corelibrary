import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates and memoizes an instance created using [builder].
/// On unmount, executes [dispose] in order to cleanup resources.
T useDisposable<T>({
  required ValueGetter<T> builder,
  required void Function(T) dispose,
  List<Object?> keys = const <Object>[],
}) {
  final value = useMemoized(builder, keys);

  useEffect(
    () => () => dispose(value),
    keys,
  );

  return value;
}
