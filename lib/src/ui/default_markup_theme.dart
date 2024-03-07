import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leancode_markup/leancode_markup.dart';
import 'package:logging/logging.dart';

/// MarkupTagStyle equivalent of DefaultTextStyle.
/// Keeps default tag styles to use in child MarkupText widgets.
class DefaultMarkupTheme extends InheritedTheme {
  const DefaultMarkupTheme({
    super.key,
    required this.tagStyles,
    this.tagFactories = const {},
    this.logger,
    required super.child,
  });

  const DefaultMarkupTheme._fallback()
      : tagStyles = const [],
        tagFactories = const {},
        logger = null,
        super(child: const SizedBox());

  /// The closest instance of this class that encloses the given context.
  ///
  /// If no such instance exists, returns an instance created by
  /// [DefaultMarkupTheme._fallback], which contains fallback values.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// DefaultMarkupTheme style = DefaultMarkupTheme.of(context);
  /// ```
  factory DefaultMarkupTheme.of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DefaultMarkupTheme>() ??
        const DefaultMarkupTheme._fallback();
  }

  /// Optional logger.
  final Logger? logger;

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
        final parent = DefaultMarkupTheme.of(context);
        return DefaultMarkupTheme(
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
  bool updateShouldNotify(DefaultMarkupTheme oldWidget) {
    return tagStyles != oldWidget.tagStyles ||
        tagFactories != oldWidget.tagFactories;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DefaultMarkupTheme(
      tagStyles: tagStyles,
      tagFactories: tagFactories,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        IterableProperty<MarkupTagStyle>('tagStyles', tagStyles),
      )
      ..add(
        DiagnosticsProperty<Map<String, MarkupTagSpanFactory>>(
          'tagFactories',
          tagFactories,
        ),
      );
  }
}
