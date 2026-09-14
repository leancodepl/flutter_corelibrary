import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// Lists this package's scopes for the check, which can glob only the package
/// it runs in.
final class ScopesManifestBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ScopesManifestBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'lib/$lib$': [manifestAsset],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Sorted, so that a clash is reported the same way on every machine.
    final sources =
        await buildStep.findAssets(Glob('**.dart')).toList()
          ..sort();

    final scopes = [
      for (final asset in sources)
        if (!asset.path.endsWith(scopesExtension))
          for (final component in await scopedComponentsIn(buildStep, asset))
            {
              'suffix': classScopeSuffix(scopeSourceOf(asset, component)),
              'owner': scopeOwnerOf(asset, component),
            },
    ];

    if (scopes.isEmpty) {
      return;
    }

    await buildStep.writeAsString(
      buildStep.allowedOutputs.single,
      jsonEncode(scopes),
    );
  }
}
