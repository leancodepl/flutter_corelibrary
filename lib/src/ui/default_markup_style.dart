import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:leancode_markup/src/ui/markup_tag_style.dart';

class DefaultMarkupStyle extends InheritedTheme {
  const DefaultMarkupStyle({
    super.key,
    required this.tags,
    required super.child,
  });

  const DefaultMarkupStyle._fallback()
      : tags = const [],
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

  static Widget merge({
    Key? key,
    required List<MarkupTagStyle> tags,
    required Widget child,
  }) {
    return Builder(
      builder: (context) {
        final parent = DefaultMarkupStyle.of(context);
        return DefaultMarkupStyle(
          key: key,
          tags: [...parent.tags, ...tags],
          child: child,
        );
      },
    );
  }

  /// The text style to apply.
  final List<MarkupTagStyle> tags;

  @override
  bool updateShouldNotify(DefaultMarkupStyle oldWidget) {
    return tags != oldWidget.tags;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DefaultMarkupStyle(
      tags: tags,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      IterableProperty<MarkupTagStyle>('tags', tags),
    );
  }
}
