import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leancode_markup/src/parser/markup_parser.dart';
import 'package:leancode_markup/src/parser/tagged_text.dart';
import 'package:leancode_markup/src/ui/default_markup_style.dart';
import 'package:leancode_markup/src/ui/markup_tag_style.dart';

class MarkupText extends StatelessWidget {
  const MarkupText(
    this.markup, {
    super.key,
    this.tags = const [],
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The markup text to display.
  final String markup;
  final List<MarkupTagStyle> tags;

  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final defaultMarkupStyle = DefaultMarkupStyle.of(context);

    final spans = [
      for (final taggedText in parseMarkup(markup))
        TextSpan(
          text: taggedText.text,
          style: _effectiveStyle(
            defaultMarkupStyle,
            tags,
            taggedText.tags,
          ),
        ),
    ];

    return Text.rich(
      TextSpan(children: spans),
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  TextStyle? _effectiveStyle(
    DefaultMarkupStyle defaultMarkupStyle,
    List<MarkupTagStyle> extraTags,
    Iterable<MarkupTag> tags,
  ) {
    TextStyle? computedStyle;

    for (final tag in tags) {
      final style = defaultMarkupStyle.tags
          .followedBy(extraTags)
          .where((e) => e.tagName == tag.name)
          .fold<TextStyle?>(null, (acc, curr) {
        final style = curr.tagStyle(tag.parameter);
        if (acc == null || !style.inherit) {
          return style;
        }
        return acc.merge(style);
      });

      // TODO: tags with no styles are ignored. Do we want to react somehow?
      computedStyle = computedStyle?.merge(style) ?? style;
    }

    return computedStyle;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('markup', markup))
      ..add(
        IterableProperty<MarkupTagStyle>('tags', tags),
      )
      ..add(
        EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null),
      )
      ..add(
        EnumProperty<TextDirection>(
          'textDirection',
          textDirection,
          defaultValue: null,
        ),
      )
      ..add(DiagnosticsProperty<Locale>('locale', locale, defaultValue: null))
      ..add(
        FlagProperty(
          'softWrap',
          value: softWrap,
          ifTrue: 'wrapping at box width',
          ifFalse: 'no wrapping except at line break characters',
          showName: true,
        ),
      )
      ..add(
        EnumProperty<TextOverflow>('overflow', overflow, defaultValue: null),
      )
      ..add(
        DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: null),
      )
      ..add(IntProperty('maxLines', maxLines, defaultValue: null))
      ..add(
        EnumProperty<TextWidthBasis>(
          'textWidthBasis',
          textWidthBasis,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<ui.TextHeightBehavior>(
          'textHeightBehavior',
          textHeightBehavior,
          defaultValue: null,
        ),
      );

    if (semanticsLabel != null) {
      properties.add(StringProperty('semanticsLabel', semanticsLabel));
    }
  }
}
