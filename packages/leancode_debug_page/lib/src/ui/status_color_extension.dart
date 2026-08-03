import 'dart:ui';

import 'package:flutter/material.dart' show Colors, ThemeData;

extension StatusColorExtension on Color {
  /// A foreground legible on a surface painted with this color.
  ///
  /// The debug page paints tiles and app bars with its own status colors, which
  /// the app's theme knows nothing about, so its `onSurface` cannot be trusted
  /// on them. [ThemeData.estimateBrightnessForColor] answers a different
  /// question - it reads mid tones like [Colors.green] as dark and would put
  /// white on them at 2.8:1 - so compare against the luminance where black and
  /// white contrast equally, `sqrt(1.05 * 0.05) - 0.05` per WCAG.
  Color get onStatusColor =>
      computeLuminance() > 0.179 ? Colors.black : Colors.white;
}
