import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart' as vg;

/// A [BytesLoader] able to distinguish xml-based svg from compiled binary form,
/// by looking for '<svg' pattern at 1000 of first characters.
/// Using logic from [AssetBytesLoader] for binaries and [SvgAssetLoader]
/// for standard xml-based format.
class LeancodeFlutterSvgAdaptiveLoader extends BytesLoader {
  /// Creates a [BytesLoader]
  const LeancodeFlutterSvgAdaptiveLoader(
    this.assetName, {
    this.packageName,
    this.assetBundle,
  });

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

  String _decode(ByteData? message, [int? lenght]) =>
      utf8.decode(message!.buffer.asUint8List(0, lenght), allowMalformed: true);

  /// This method intentionally avoids using `await` to avoid unnecessary event
  /// loop turns. This is meant to to help tests in particular.
  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    return _prepareMessage(context).then((message) {
      // Dart encodes strings in UTF-16 so one codepoint is 2 bytes
      final first1000Chars = _decode(message, min(2000, message.lengthInBytes));

      if (first1000Chars.contains('<svg')) {
        return svg.cache.putIfAbsent(
          cacheKey(context),
          () => _loadSvg(context, message),
        );
      } else {
        return message;
      }
    });
  }

  Future<ByteData> _loadSvg(
    BuildContext? context,
    ByteData? message,
  ) {
    return compute(
      (message) {
        return vg
            .encodeSvg(
              xml: _decode(message),
              debugName: 'Svg loader',
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
  Object cacheKey(BuildContext? context) {
    return _AssetByteLoaderCacheKey(
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
    return other is LeancodeFlutterSvgAdaptiveLoader &&
        other.assetName == assetName &&
        other.packageName == packageName &&
        other.assetBundle == assetBundle;
  }
}

// Replaces the cache key for [AssetBytesLoader] to account for the fact that
// different widgets may select a different asset bundle based on the return
// value of `DefaultAssetBundle.of(context)`.
@immutable
class _AssetByteLoaderCacheKey {
  const _AssetByteLoaderCacheKey(
    this.assetName,
    this.packageName,
    this.assetBundle,
  );

  final String assetName;
  final String? packageName;

  final AssetBundle assetBundle;

  @override
  int get hashCode => Object.hash(assetName, packageName, assetBundle);

  @override
  bool operator ==(Object other) {
    return other is _AssetByteLoaderCacheKey &&
        other.assetName == assetName &&
        other.assetBundle == assetBundle &&
        other.packageName == packageName;
  }

  @override
  String toString() =>
      'VectorGraphicAsset(${packageName != null ? '$packageName/' : ''}$assetName)';
}
