import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Registers [effect] to be run in
/// WidgetsBinding.instance.addPostFrameCallback.
void usePostFrameEffect(VoidCallback effect, [List<Object?>? keys]) {
  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) => effect());
      return null;
    },
    keys,
  );
}
