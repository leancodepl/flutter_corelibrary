import 'package:enhanced_gradients/src/gradient_approximation.dart';
import 'package:enhanced_gradients/src/hct_color_tween.dart';
import 'package:flutter/painting.dart';

/// Global singleton with default configuration for enhanced gradients.
sealed class EnhancedGradientsGlobalConfig {
  static int _approximationSubdivisions = 6;

  /// The higher this number, the smoother the gradient. Cannot be less than 0.
  static int get approximationSubdivisions => _approximationSubdivisions;
  static set approximationSubdivisions(int value) {
    assert(value >= 0);
    _approximationSubdivisions = value;
  }
}

/// Provides the [enhanced] method on [LinearGradient].
extension EnhancedLinearGradientExtension on LinearGradient {
  /// Modifies the gradient's [colors] and [stops] parameters to obtain
  /// a (subjectively) more appealing transition.
  LinearGradient enhanced({
    int? approximationSubdivisions,
  }) {
    final (hctColors, hctStops) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return LinearGradient(
      colors: hctColors,
      stops: hctStops,
      begin: begin,
      end: end,
      tileMode: tileMode,
      transform: transform,
    );
  }
}

/// Provides the [enhanced] method on [RadialGradient].
extension EnhancedRadialGradientExtension on RadialGradient {
  /// Modifies the gradient's [colors] and [stops] parameters to obtain
  /// a (subjectively) more appealing transition.
  RadialGradient enhanced({
    int? approximationSubdivisions,
  }) {
    final (hctColors, hctStops) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return RadialGradient(
      colors: hctColors,
      stops: hctStops,
      center: center,
      focal: focal,
      focalRadius: focalRadius,
      radius: radius,
      tileMode: tileMode,
      transform: transform,
    );
  }
}

/// Provides the [enhanced] method on [SweepGradient].
extension EnhancedSweepGradientExtension on SweepGradient {
  /// Modifies the gradient's [colors] and [stops] parameters to obtain
  /// a (subjectively) more appealing transition.
  SweepGradient enhanced({
    int? approximationSubdivisions,
  }) {
    final (hctColors, hctStops) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return SweepGradient(
      colors: hctColors,
      stops: hctStops,
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
      tileMode: tileMode,
      transform: transform,
    );
  }
}
