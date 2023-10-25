import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:leancode_flutter_svg_adaptive_loader/src/compute.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vg;

/// A [BytesLoader] able to distinguish xml-based svg from a compiled binary form,
/// by looking for UTF-8 decoder [_replacementCharacter]s on the first 100 characters.
/// Using logic from [AssetBytesLoader] for binaries and [SvgAssetLoader]
/// for standard xml-based format.
class FlutterSvgAdaptiveLoader extends BytesLoader {
  /// Creates a [BytesLoader]
  const FlutterSvgAdaptiveLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
  });

  /// UTF-8 decoder replacement character
  static const _replacementCharacter = 0xFFFD;

  /// The name of the asset to load.
  final String assetName;

  /// The package name to load from, if any.
  final String? packageName;

  /// The asset bundle to use.
  ///
  /// If unspecified, [DefaultAssetBundle.of] the current context will be used.
  final AssetBundle? assetBundle;

  AssetBundle _resolveBundle(BuildContext? context) {
    if (assetBundle != null) {
      return assetBundle!;
    }
    if (context != null) {
      return DefaultAssetBundle.of(context);
    }
    return rootBundle;
  }

  Future<ByteData> _prepareMessage(BuildContext? context) {
    return _resolveBundle(context).load(
      packageName == null ? assetName : 'packages/$packageName/$assetName',
    );
  }

  String _decode(ByteData message, [int? length]) =>
      utf8.decode(message.buffer.asUint8List(0, length), allowMalformed: true);

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    return _prepareMessage(context).then((message) {
      // Dart encodes strings in UTF-16 so one codepoint is 2 bytes
      final first100Chars = _decode(message, min(200, message.lengthInBytes));
      final invalidCodePoints = first100Chars.codeUnits
          .where((e) => e == _replacementCharacter)
          .length;

      // One invalid code point is still acceptable since the last code point
      // could have been longer than 1 code unit and gotten cut a part
      // of the code units
      if (invalidCodePoints > 1) {
        // Invalid UTF-8 encoded string - process as a binary vector
        return message;
      } else {
        // Valid UTF-8 encoded string - process as a svg vector
        return svg.cache.putIfAbsent(
          cacheKey(context),
          () => _loadSvg(message),
        );
      }
    });
  }

  Future<ByteData> _loadSvg(ByteData message) {
    return compute(
      (message) {
        return vg
            .encodeSvg(
              xml: _decode(message),
              debugName: 'Svg loader $assetName',
              enableClippingOptimizer: false,
              enableMaskingOptimizer: false,
              enableOverdrawOptimizer: false,
            )
            .buffer
            .asByteData();
      },
      message,
      debugLabel: 'Load Bytes',
    );
  }

  @override
  _AssetByteLoaderCacheKey cacheKey(BuildContext? context) {
    return (
      assetName,
      packageName,
      _resolveBundle(context),
    );
  }

  @override
  String toString() =>
      'VectorGraphicAsset(${packageName != null ? '$packageName/' : ''}$assetName)';

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is FlutterSvgAdaptiveLoader &&
        other.assetName == assetName &&
        other.packageName == packageName &&
        other.assetBundle == assetBundle;
  }
}

typedef _AssetByteLoaderCacheKey = (
  String assetName,
  String? packageName,
  AssetBundle assetBundle
);
