# leancode_flutter_svg_adaptive_loader

[![leancode_flutter_svg_adaptive_loader pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

This package adds an adaptive bytes loader for `.svg` and `.svg.vec` assets.
While loading the asset, the loader checks if format of the file is xml-based or binary, loading it accordingly to the format.

## Motivation

Motivation to create this package was a possibility to keep the original xml-based vector assets in your repository, while compiling them in your CI/CD process in order to minify their size and time-to-load.
Assuming that debug environment would use xml-based assets, while release app would use a compiled binary, it requires a way of checking the vector format. `FlutterSvgAdaptiveLoader` is designed to relieve the programmer of this responsibility.

In order to make all that working we recommend to keep the `.svg` extension instead of `.svg.vec` for compiled vectors when compiling assets in the CI/CD process. A change to the extension would require updating the assets paths accordingly in the code.

## Usage

To use adaptive svg loader simply pass `FlutterSvgAdaptiveLoader` object into your `SvgPicture`:

```dart
SvgPicture(FlutterSvgAdaptiveLoader('assets/foo.svg')),
```

If you are using [flutter_gen package](https://pub.dev/packages/flutter_gen) you can copy the code below and use `.adaptiveSvg()` method being extension on `SvgGenImage`.

```dart
import 'package:leancode_flutter_svg_adaptive_loader/leancode_flutter_svg_adaptive_loader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
// TODO: Add an import for `SvgGenImage` created by `flutter_gen`

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
      FlutterSvgAdaptiveLoader(
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
