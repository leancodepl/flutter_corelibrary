import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature of function that is returned by [useDebounce].
typedef DebouncedCallback = void Function(VoidCallback callback);

/// Returns a function whose invocation will be delayed by [duration].
///
/// When the returned function is called again, the previous (scheduled)
/// invocation is canceled.
///
/// See also:
///
///  * <https://rxmarbles.com/#debounce>, which this hook implements.
DebouncedCallback useDebounce(Duration duration) {
  final debouncer = useMemoized(() => _Debouncer(duration), [duration]);
  return debouncer.run;
}

class _Debouncer {
  _Debouncer(this.duration);

  final Duration duration;

  Timer? _timer;

  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }
}
