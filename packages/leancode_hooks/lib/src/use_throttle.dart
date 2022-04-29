import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature for function that is returned from [useThrottle].
typedef ThrottledFunc = void Function(VoidCallback callback);

/// Returns a function that can be called only once per [duration].
///
/// When [ThrottledFunc] that this hook returns is called, a cooldown of
/// [duration] is started. During it, any calls to [ThrottledFunc] are ignored.
ThrottledFunc useThrottle(Duration duration) {
  final throttler = useMemoized(() => _Throttler(duration), [duration]);
  return throttler.run;
}

class _Throttler {
  _Throttler(this.duration);

  final Duration duration;

  bool _locked = false;

  Future<void> run(VoidCallback fun) async {
    if (!_locked) {
      _locked = true;
      fun();
      await Future<void>.delayed(duration);
      _locked = false;
    }
  }
}
