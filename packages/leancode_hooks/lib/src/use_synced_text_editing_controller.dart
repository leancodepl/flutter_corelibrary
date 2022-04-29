import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

TextEditingController useSyncedTextEditingController(
  void Function(TextEditingValue value) onChanged, {
  String? initialText,
}) {
  final controller = useTextEditingController(text: initialText);

  void listener() => onChanged(controller.value);

  useEffect(
    () {
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    },
    [controller, onChanged],
  );

  return controller;
}
