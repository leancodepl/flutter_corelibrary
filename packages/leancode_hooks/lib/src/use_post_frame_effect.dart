import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Registers [effect] to be run in
/// [WidgetsBinding.addPostFrameCallback].
void usePostFrameEffect(
  VoidCallback effect, {
  List<Object?>? keys = const [],
}) {
  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) => effect());
      return null;
    },
    keys,
  );
}
