import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A wrapper around [useTextEditingController] that updates
/// [TextEditingController.text] when the text changes.
///
/// Does not handle some edge cases with the current cursor/selection.
TextEditingController useDeclarativeTextEditingController({
  required String text,
}) {
  final controller = useTextEditingController(text: text);

  useEffect(
    () {
      if (controller.text != text) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.text = text;
        });
      }
      return null;
    },
    [text],
  );

  return controller;
}
