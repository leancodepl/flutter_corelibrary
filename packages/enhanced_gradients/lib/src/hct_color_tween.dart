import 'dart:ui';

import 'package:enhanced_gradients/src/lerp_utils.dart';
import 'package:flutter/animation.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// A Color [Tween] interpolated in the HCT color space provided by the package
/// material_color_utilities. See [Hct]. For raw interpolation function
/// see [lerpHct].
class HctColorTween extends Tween<Color?> {
  /// Creates a tween.
  HctColorTween({super.begin, super.end});

  @override
  Color? lerp(double t) => lerpHct(begin, end, t);
}

/// Linearly interpolates input [Color]s in [Hct] color system's coordinates,
/// as opposed to [Color.lerp] that interpolates its raw ARGB constituents.
/// For a [Tween] see [HctColorTween].
Color? lerpHct(Color? colorA, Color? colorB, double t) =>
    switch ((colorA, colorB)) {
      (null, null) => null,
      (final colorA?, null) => _scaleAlpha(colorA, 1 - t),
      (null, final colorB?) => _scaleAlpha(colorB, t),
      (final colorA?, final colorB?) => _lerpHctNonNullable(colorA, colorB, t),
    };

Color _lerpHctNonNullable(Color colorA, Color colorB, double t) {
  final beginHct = Hct.fromInt(_colorToInt(colorA));
  final endHct = Hct.fromInt(_colorToInt(colorB));

  final alpha = lerpDouble(colorA.a, colorB.a, t)!;
  final hue = lerpDegrees(beginHct.hue, endHct.hue, t)!;
  final chroma = lerpDouble(beginHct.chroma, endHct.chroma, t)!;
  final tone = lerpDouble(beginHct.tone, endHct.tone, t)!;

  return Color(
    Hct.from(hue, chroma, tone).toInt(),
  ).withValues(alpha: alpha);
}

Color _scaleAlpha(Color color, double factor) {
  return color.withValues(alpha: color.a * factor);
}

/// [Hct] requires int values, so we need to convert [Color].
int _colorToInt(Color color) {
  return _floatToInt8(color.a) << 24 |
      _floatToInt8(color.r) << 16 |
      _floatToInt8(color.g) << 8 |
      _floatToInt8(color.b) << 0;
}

int _floatToInt8(double x) {
  return (x * 255.0).round() & 0xff;
}
