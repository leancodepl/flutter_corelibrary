import 'package:flutter/painting.dart';

typedef TagStyleCreator = TextStyle Function(String? parameter);

abstract class MarkupTagStyle {
  const MarkupTagStyle(this.tagName);

  factory MarkupTagStyle.delegate({
    required String tagName,
    required TagStyleCreator styleCreator,
  }) =>
      _MarkupTagStyle(tagName, styleCreator);

  final String tagName;

  TextStyle tagStyle(String? parameter);
}

class _MarkupTagStyle extends MarkupTagStyle {
  const _MarkupTagStyle(super.tagName, this.styleCreator);

  final TagStyleCreator styleCreator;

  @override
  TextStyle tagStyle(String? parameter) => styleCreator(parameter);
}
