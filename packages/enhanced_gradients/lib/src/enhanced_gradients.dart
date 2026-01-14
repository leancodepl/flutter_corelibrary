import 'dart:math' as math;

import 'package:enhanced_gradients/src/enhanced_gradient_extension.dart';
import 'package:enhanced_gradients/src/gradient_approximation.dart';
import 'package:enhanced_gradients/src/hct_color_tween.dart';
import 'package:flutter/material.dart';

/// A slightly modified [LinearGradient] that applies a smoother color
/// transition in the HCT color space.
class EnhancedLinearGradient extends LinearGradient {
  /// Builds the gradient. See the [LinearGradient.new] constructor for details.
  factory EnhancedLinearGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    required List<Color> colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    int? approximationSubdivisions,
  }) {
    final (
      hctColors,
      hctStops,
    ) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return EnhancedLinearGradient._(
      begin: begin,
      end: end,
      colors: hctColors,
      stops: hctStops,
      tileMode: tileMode,
      transform: transform,
    );
  }

  const EnhancedLinearGradient._({
    required super.begin,
    required super.end,
    required super.colors,
    required super.stops,
    required super.tileMode,
    required super.transform,
  });

  @override
  EnhancedLinearGradient withOpacity(double opacity) {
    return EnhancedLinearGradient._(
      begin: begin,
      end: end,
      colors: [
        for (final Color color in colors) color.withValues(alpha: opacity),
      ],
      stops: stops,
      tileMode: tileMode,
      transform: transform,
    );
  }
}

/// A slightly modified [RadialGradient] that applies a smoother color
/// transition in the HCT color space.
class EnhancedRadialGradient extends RadialGradient {
  /// Builds the gradient. See the [RadialGradient.new] constructor for details.
  factory EnhancedRadialGradient({
    AlignmentGeometry center = Alignment.center,
    AlignmentGeometry? focal,
    double focalRadius = 0.0,
    double radius = 0.5,
    required List<Color> colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    int? approximationSubdivisions,
  }) {
    final (
      hctColors,
      hctStops,
    ) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return EnhancedRadialGradient._(
      center: center,
      focal: focal,
      focalRadius: focalRadius,
      radius: radius,
      colors: hctColors,
      stops: hctStops,
      tileMode: tileMode,
      transform: transform,
    );
  }
  const EnhancedRadialGradient._({
    required super.center,
    required super.focal,
    required super.focalRadius,
    required super.radius,
    required super.colors,
    required super.stops,
    required super.tileMode,
    required super.transform,
  });
}

/// A slightly modified [SweepGradient] that applies a smoother color
/// transition in the HCT color space.
class EnhancedSweepGradient extends SweepGradient {
  /// Builds the gradient. See the [SweepGradient.new] constructor for details.
  factory EnhancedSweepGradient({
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0,
    double endAngle = math.pi * 2,
    required List<Color> colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    int? approximationSubdivisions,
  }) {
    final (
      hctColors,
      hctStops,
    ) = approximateGradientLists(
      colors: colors,
      stops: stops,
      lerp: lerpHct,
      subdivisions: approximationSubdivisions ??
          EnhancedGradientsGlobalConfig.approximationSubdivisions,
    );

    return EnhancedSweepGradient._(
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
      colors: hctColors,
      stops: hctStops,
      tileMode: tileMode,
      transform: transform,
    );
  }
  const EnhancedSweepGradient._({
    required super.center,
    required super.startAngle,
    required super.endAngle,
    required super.colors,
    required super.stops,
    required super.tileMode,
    required super.transform,
  });
}
