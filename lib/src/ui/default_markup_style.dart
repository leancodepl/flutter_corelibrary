import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leancode_markup/leancode_markup.dart';

/// MarkupTagStyle equivalent of DefaultTextStyle.
/// Keeps default tag styles to use in child MarkupText widgets.
class DefaultMarkupStyle extends InheritedTheme {
  const DefaultMarkupStyle({
    super.key,
    required this.tagStyles,
    this.tagFactories = const {},
    required super.child,
  });

  const DefaultMarkupStyle._fallback()
      : tagStyles = const [],
        tagFactories = const {},
        super(child: const SizedBox());

  /// The closest instance of this class that encloses the given context.
  ///
  /// If no such instance exists, returns an instance created by
  /// [DefaultMarkupStyle._fallback], which contains fallback values.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DefaultMarkupStyle style = DefaultMarkupStyle.of(context);
  /// ```
  factory DefaultMarkupStyle.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultMarkupStyle>() ??
        const DefaultMarkupStyle._fallback();
  }

  /// List of basic tag styles, that provide support for bold, italic and underlined
  /// text styles. Prepared for quick use.
  static final List<MarkupTagStyle> basicTags = [
    MarkupTagStyle.delegate(
      tagName: 'b',
      styleCreator: (_) => const TextStyle(fontWeight: FontWeight.bold),
    ),
    MarkupTagStyle.delegate(
      tagName: 'i',
      styleCreator: (_) => const TextStyle(fontStyle: FontStyle.italic),
    ),
    MarkupTagStyle.delegate(
      tagName: 'u',
      styleCreator: (_) =>
          const TextStyle(decoration: TextDecoration.underline),
    ),
  ];

  static Widget merge({
    Key? key,
    required List<MarkupTagStyle> tagStyles,
    required Map<String, MarkupTagSpanFactory> tagFactories,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        final parent = DefaultMarkupStyle.of(context);
        return DefaultMarkupStyle(
          key: key,
          tagStyles: [...parent.tagStyles, ...tagStyles],
          tagFactories: {...parent.tagFactories, ...tagFactories},
          child: child,
        );
      },
    );
  }

  /// The text style to apply.
  final List<MarkupTagStyle> tagStyles;

  /// Tag factories to apply.
  final Map<String, MarkupTagSpanFactory> tagFactories;

  @override
  bool updateShouldNotify(DefaultMarkupStyle oldWidget) {
    return tagStyles != oldWidget.tagStyles;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DefaultMarkupStyle(
      tagStyles: tagStyles,
      tagFactories: tagFactories,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      IterableProperty<MarkupTagStyle>('tagStyles', tagStyles),
    );
  }
}
