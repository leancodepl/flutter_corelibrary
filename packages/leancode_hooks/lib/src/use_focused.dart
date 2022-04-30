import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

bool useFocused(FocusNode focusNode) {
  return useListenable(focusNode).hasFocus;
}
