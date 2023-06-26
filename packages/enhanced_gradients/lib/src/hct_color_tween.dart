import 'dart:ui';

import 'package:enhanced_gradients/src/lerp_utils.dart';
import 'package:flutter/animation.dart';
import 'package:material_color_utilities/hct/hct_solver.dart';
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
  final beginHct = Hct.fromInt(colorA.value);
  final endHct = Hct.fromInt(colorB.value);

  final opacity = lerpDouble(colorA.opacity, colorB.opacity, t)!;
  final hue = lerpDegrees(beginHct.hue, endHct.hue, t)!;
  final chroma = lerpDouble(beginHct.chroma, endHct.chroma, t)!;
  final tone = lerpDouble(beginHct.tone, endHct.tone, t)!;

  return Color(
    // This is a slight optimization over calling
    // `Hct.from(hue, chroma, tone).toInt()`
    HctSolver.solveToInt(hue, chroma, tone),
  ).withOpacity(opacity);
}

Color _scaleAlpha(Color a, double factor) {
  return a.withAlpha((a.alpha * factor).round().clamp(0, 255));
}
