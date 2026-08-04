import 'dart:math';

import 'package:flutter/material.dart';

/// The luminance at which black and white contrast equally.
///
/// WCAG rates the contrast of two luminances as
/// `(lighter + 0.05) / (darker + 0.05)`, so this solves
/// `1.05 / (l + 0.05) == (l + 0.05) / 0.05` - the point where a foreground is
/// no better off white than black.
final _equalContrastLuminance = sqrt(1.05 * 0.05) - 0.05;

extension StatusColorExtension on Color {
  /// A foreground legible on a surface painted with this color.
  ///
  /// The debug page paints tiles and app bars with its own status colors, which
  /// the app's theme knows nothing about, so its `onSurface` cannot be trusted
  /// on them. [ThemeData.estimateBrightnessForColor] answers a different
  /// question - it reads mid tones like [Colors.green] as dark and would put
  /// white on them at 2.8:1.
  Color get onStatusColor => computeLuminance() > _equalContrastLuminance
      ? Colors.black
      : Colors.white;
}
