import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature for function that is returned from [useCooldown].
typedef CooledDown = void Function(VoidCallback callback);

/// Limits function calls to once per [duration].
///
/// When [CooledDown] function that this hook returns is called, a cooldown of
/// [duration] is started. During it, any calls to [CooledDown] function are
/// ignored.
CooledDown useCooldown(
  Duration duration, [
  List<Object?> keys = const <Object>[],
]) {
  final debouncer = useMemoized(() => _Cooldowner(duration), keys);
  return debouncer.run;
}

class _Cooldowner {
  _Cooldowner(this.duration);

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
