import 'dart:convert';

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/context/packages.dart';
import 'package:analyzer/src/workspace/pub.dart';
import 'package:analyzer/workspace/workspace.dart';
import 'package:leancode_lint/src/helpers.dart';
import 'package:test/test.dart';

void main() {
  late MemoryResourceProvider provider;
  late String rootPath;

  String inRoot(List<String> parts) =>
      provider.pathContext.joinAll([rootPath, ...parts]);

  WorkspacePackage? buildPackage({
    List<String> dependencies = const [],
    List<String> devDependencies = const [],
  }) {
    String section(String name, List<String> packages) => packages.isEmpty
        ? ''
        : '$name:\n${packages.map((p) => '  $p: any\n').join()}';

    provider.newFile(
      inRoot(['pubspec.yaml']),
      '''
name: my_app
${section('dependencies', dependencies)}${section('dev_dependencies', devDependencies)}''',
    );

    final packageConfigFile = provider.newFile(
      inRoot(['.dart_tool', 'package_config.json']),
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {'name': 'my_app', 'rootUri': '../', 'packageUri': 'lib/'},
          // Resolvable, but not declared by `my_app` unless a test says so.
          {
            'name': 'collection',
            'rootUri': '/pub-cache/collection',
            'packageUri': 'lib/',
          },
        ],
      }),
    );

    return PackageConfigWorkspace(
      provider,
      rootPath,
      packageConfigFile,
      Packages.empty,
    ).findPackageFor(inRoot(['lib', 'a.dart']));
  }

  setUp(() {
    provider = MemoryResourceProvider();
    rootPath = provider.pathContext.join(
      provider.pathContext.rootPrefix(provider.pathContext.current),
      'home',
      'my_app',
    );
  });

  test('finds a direct dependency', () {
    expect(
      packageDependsOn(
        'collection',
        package: buildPackage(dependencies: ['collection']),
        filePath: inRoot(['lib', 'a.dart']),
      ),
      isTrue,
    );
  });

  test('does not find a package that is only transitively available', () {
    expect(
      packageDependsOn(
        'collection',
        package: buildPackage(dependencies: ['flutter']),
        filePath: inRoot(['lib', 'a.dart']),
      ),
      isFalse,
    );
  });

  test('ignores dev dependencies for files in public directories', () {
    final package = buildPackage(devDependencies: ['collection']);

    for (final path in [
      inRoot(['lib', 'a.dart']),
      inRoot(['lib', 'src', 'a.dart']),
      inRoot(['bin', 'a.dart']),
      inRoot(['hook', 'build.dart']),
    ]) {
      expect(
        packageDependsOn('collection', package: package, filePath: path),
        isFalse,
        reason: path,
      );
    }
  });

  test('accepts dev dependencies elsewhere', () {
    final package = buildPackage(devDependencies: ['collection']);

    for (final path in [
      inRoot(['test', 'a_test.dart']),
      inRoot(['tool', 'a.dart']),
      inRoot(['example', 'lib', 'a.dart']),
    ]) {
      expect(
        packageDependsOn('collection', package: package, filePath: path),
        isTrue,
        reason: path,
      );
    }
  });

  test('returns false when the file has no package', () {
    expect(
      packageDependsOn(
        'collection',
        package: null,
        filePath: inRoot(['lib', 'a.dart']),
      ),
      isFalse,
    );
  });
}
