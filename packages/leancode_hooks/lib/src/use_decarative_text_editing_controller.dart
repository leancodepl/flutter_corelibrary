import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

TextEditingController useDeclarativeTextEditingController({
  required String text,
}) {
  final controller = useTextEditingController(text: text);

  useEffect(
    () {
      if (controller.text != text) {
        WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
          controller.text = text;
        });
      }
      return null;
    },
    [text],
  );

  return controller;
}
