import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:jaspr_class_scope_builder/src/class_scope_builder.dart';

/// Fails the build when two components in this package took one suffix.
///
/// [ClassScopeBuilder] hashes the asset a component is declared in, so two
/// components can only meet by hashing alike — five base-36 digits leave room
/// for that, rarely. This runs once per package, after the scopes are written,
/// and reads them back: a clash is a build error naming both components, not
/// something a page discovers while rendering.
final class ClassScopeCheckBuilder implements Builder {
  /// The builder `build.yaml` instantiates.
  const ClassScopeCheckBuilder();

  static final _scope = RegExp(r"ClassScope\.literal\('([^']+)', '([^']+)'\)");

  @override
  Map<String, List<String>> get buildExtensions => const {
    r'$package$': ['jaspr_class_scope.check'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final owners = <String, String>{};
    final report = StringBuffer();

    final scopes =
        await buildStep
            .findAssets(Glob('**${ClassScopeBuilder.outputExtension}'))
            .toList();
    // Sorted, so that a clash is reported the same way on every machine.
    scopes.sort((a, b) => a.compareTo(b));

    for (final asset in scopes) {
      final content = await buildStep.readAsString(asset);

      for (final scope in _scope.allMatches(content)) {
        final component = '${scope.group(1)} (${asset.path})';
        final suffix = scope.group(2)!;

        final taken = owners.putIfAbsent(suffix, () => component);
        if (taken != component) {
          throw StateError(
            '$component and $taken both scope to "-$suffix". Rename or move '
            'one of them; the suffix is hashed from the file a component is '
            'declared in.',
          );
        }

        report.writeln('$suffix $component');
      }
    }

    await buildStep.writeAsString(
      buildStep.allowedOutputs.single,
      report.toString(),
    );
  }
}
