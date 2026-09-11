import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// Fails the build when two components in this package end up with the same
/// suffix, which would put their class names in one scope.
///
/// Hashes the sources, not the generated part files, so a change in how the
/// generated code is spelled cannot leave it checking nothing.
final class ClassScopeCheckBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ClassScopeCheckBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$package$': ['jaspr_class_scope.check'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Sorted, so that a clash is reported the same way on every machine.
    final sources =
        await buildStep.findAssets(Glob('**.dart')).toList()
          ..sort();

    final owners = <String, String>{};
    final scopes = StringBuffer();

    for (final asset in sources) {
      if (asset.path.endsWith(scopesExtension)) {
        continue;
      }

      for (final component in scopedComponentsIn(
        await buildStep.readAsString(asset),
      )) {
        final suffix = classScopeSuffix(scopeSourceOf(asset, component));
        final owner = '$component (${asset.path})';

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
