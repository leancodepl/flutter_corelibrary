import 'dart:convert';

import 'package:build/build.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';

/// Fails the build when two components end up with the same suffix, which
/// would put their class names in one scope.
///
/// Reads the manifest of every package in the build, so it sees the components
/// of a dependency as well as this package's own.
final class ClassScopeCheckBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ClassScopeCheckBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$package$': ['jaspr_class_scope.check'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // A set, because `packageConfig` lists this package too, and reading one
    // manifest twice would read a clash into it.
    final packages = {
      buildStep.inputId.package,
      ...(await buildStep.packageConfig).packages.map((it) => it.name),
    };

    final owners = <String, String>{};
    final scopes = StringBuffer();

    // Sorted, so that a clash is reported the same way on every machine.
    for (final package in packages.toList()..sort()) {
      final manifest = AssetId(package, manifestAsset);
      if (!await buildStep.canRead(manifest)) {
        continue;
      }

      final listed =
          (jsonDecode(await buildStep.readAsString(manifest)) as List<Object?>)
              .cast<Map<String, Object?>>();

      for (final {'suffix': suffix as String, 'owner': owner as String}
          in listed) {
        final taken = owners[suffix];
        if (taken != null) {
          throw StateError(
            '$owner and $taken both scope to the same suffix. Rename or move '
            'one of them.',
          );
        }
        owners[suffix] = owner;

        scopes.writeln('$suffix $owner');
      }
    }

    await buildStep.writeAsString(
      buildStep.allowedOutputs.single,
      scopes.toString(),
    );
  }
}
