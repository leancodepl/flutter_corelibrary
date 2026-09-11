import 'dart:convert';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// Lists this package's scopes into its `lib/`, the one directory of a
/// dependency that another package's build can read. The check can glob only
/// the package it runs in, so this is what lets it see a dependency's
/// components.
///
/// Hashes the sources, not the generated part files, so a change in how the
/// generated code is spelled cannot leave the check checking nothing.
final class ScopesManifestBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ScopesManifestBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'lib/$lib$': [manifestPath],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Sorted, so that a clash is reported the same way on every machine.
    final sources =
        await buildStep.findAssets(Glob('**.dart')).toList()
          ..sort();

    final scopes = <Map<String, String>>[];

    for (final asset in sources) {
      if (asset.path.endsWith(scopesExtension)) {
        continue;
      }

      for (final component in scopedComponentsIn(
        await buildStep.readAsString(asset),
      )) {
        scopes.add({
          'suffix': classScopeSuffix(scopeSourceOf(asset, component)),
          'owner': scopeOwnerOf(asset, component),
        });
      }
    }

    if (scopes.isEmpty) {
      return;
    }

    await buildStep.writeAsString(
      buildStep.allowedOutputs.single,
      jsonEncode(scopes),
    );
  }
}
