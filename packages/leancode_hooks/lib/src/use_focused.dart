import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Subscribes to [focusNode] changes and marks the widget as needing build
/// whenever they happen. Returns whether [focusNode] has focus.
bool useFocused(FocusNode focusNode) {
  return useListenable(focusNode).hasFocus;
}
