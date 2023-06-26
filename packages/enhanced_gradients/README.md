# enhanced_gradients

This package adds an easy way to enhance your Flutter gradients and color transitions by interpolating colors
in the HCT color system provided by the [material_color_utilities package](https://pub.dev/packages/material_color_utilities).

## Usage

The package exposes two ways to modify the built-in `LinearGradient`, `RadialGradient` and `SweepGradient` gradients:

```dart
// 1st way: extension method

LinearGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
).enhanced()

RadialGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
).enhanced()

SweepGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
).enhanced()
```

```dart
// 2nd way: `Enhanced*Gradient` class

EnhancedLinearGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
)

EnhancedRadialGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
)

EnhancedSweepGradient(
  colors: const [Color(0xFF000000), Color(0xFFFFFFFF)],
  // ...
)
```

There is also a `HctColorTween` that can be used instead of the regular `ColorTween` to interpolate
colors in the HCT color system in Flutter animations.
