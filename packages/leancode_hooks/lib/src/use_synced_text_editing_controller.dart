import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A wrapper around [useTextEditingController] that makes it easier to add
/// [onChanged] callback to [TextEditingController].
TextEditingController useSyncedTextEditingController(
  void Function(TextEditingValue value) onChanged, {
  String? initialText,
}) {
  final controller = useTextEditingController(text: initialText);

  useEffect(
    () {
      void listener() => onChanged(controller.value);

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    },
    [controller, onChanged],
  );

  return controller;
}
