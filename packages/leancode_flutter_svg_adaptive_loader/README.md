# leancode_flutter_svg_adaptive_loader

[![leancode_flutter_svg_adaptive_loader pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

This package adds an adaptive bytes loader for `.svg` assets. That allows you to compile your vector assets by `vector_graphics_compiler`
into binary either inside of your repository or on CI/CD, without thinking in-code whether the asset is xml-based or a compiled binary.

## Usage

To use adaptive svg loader simply pass `LeancodeFlutterSvgAdaptiveLoader` object into your `SvgPicture`:

```dart
SvgPicture(LeancodeFlutterSvgAdaptiveLoader('assets/foo.svg')),
```

If you are using [flutter_gen package](https://pub.dev/packages/flutter_gen) you can copy the code below and use `.adaptiveSvg()` method being extension on `SvgGenImage`.

```dart
import 'package:leancode_flutter_svg_adaptive_loader/leancode_flutter_svg_adaptive_loader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
/// TODO: Add an import for `SvgGenImage` created by `flutter_gen`

extension AdaptiveSvgGenImage on SvgGenImage {
  SvgPicture adaptiveSvg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
  }) {
    return SvgPicture(
      LeancodeFlutterSvgAdaptiveLoader(
        path,
        assetBundle: bundle,
        packageName: package,
      ),
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter,
      clipBehavior: clipBehavior,
    );
  }
}
```

To use that extension simply call it on your desired asset generated class

```dart
Assets.foo.adaptiveSvg()
```

[pub-badge]: https://img.shields.io/pub/v/leancode_flutter_svg_adaptive_loader
[pub-badge-link]: https://pub.dev/packages/leancode_flutter_svg_adaptive_loader
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_flutter_svg_adaptive_loader-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_flutter_svg_adaptive_loader-test.yml
