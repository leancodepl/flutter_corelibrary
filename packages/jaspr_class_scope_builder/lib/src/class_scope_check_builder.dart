import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr_class_scope_builder/src/scoped_components.dart';
import 'package:jaspr_class_scope_builder/src/suffix.dart';

/// Fails the build when two components in this package took one suffix.
///
/// Six base-36 digits leave room for two of them to hash alike, rarely. This
/// runs once per package and hashes every annotated component the way
/// the scope builder does, so a clash is a build error naming both files
/// rather than something a page discovers while rendering.
///
/// It reads the components out of the sources rather than out of the generated
/// part files: the suffix is a function of where a class is declared, so the
/// check needs no more than the generator does, and cannot go blind if the
/// generated code is ever rendered differently.
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
            '$owner and $taken both scope to "-$suffix". Rename or move one of '
            'them; the suffix is hashed from where a component is declared.',
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
