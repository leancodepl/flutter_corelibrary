import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature of function that is returned by [useThrottle].
typedef ThrottledCallback = void Function(VoidCallback callback);

/// Returns a function that can be called only once per [duration].
///
/// When the returned function is called, a cooldown of [duration] is started.
/// During its duration, any calls to the returned function are ignored.
///
/// See also:
///
/// * <https://rxmarbles.com/#throttle>, which this hook implements.
ThrottledCallback useThrottle(Duration duration) {
  final throttler = useMemoized(() => _Throttler(duration), [duration]);
  return throttler.run;
}

class _Throttler {
  _Throttler(this.duration);

  final Duration duration;

  bool _locked = false;

  Future<void> run(VoidCallback callback) async {
    if (!_locked) {
      _locked = true;
      callback();
      await Future<void>.delayed(duration);
      _locked = false;
    }
  }
}
