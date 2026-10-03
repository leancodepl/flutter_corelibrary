import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:leancode_lint/src/helpers.dart';
import 'package:test/test.dart';

void main() {
  late MemoryResourceProvider provider;

  setUp(() {
    provider = MemoryResourceProvider();
  });

  /// Turns a posix-style absolute [path] into one of the memory file system.
  String absolute(String path) => provider.pathContext.joinAll([
    provider.pathContext.rootPrefix(provider.pathContext.current),
    ...path.split('/').skip(1),
  ]);

  File write(String path, String content) =>
      provider.newFile(absolute(path), content);

  /// Resolves `package:name/path` to `/pub/name/lib/path`.
  String? resolveUri(Uri uri) => switch (uri) {
    Uri(scheme: 'package', pathSegments: [final package, ...final path]) =>
      absolute('/pub/$package/lib/${path.join('/')}'),
    _ => null,
  };

  Set<String> enabledIn(File file) =>
      lintsEnabledIn(file, resolveUri: resolveUri);

  test('reads a list of rules', () {
    final options = write('/app/analysis_options.yaml', '''
linter:
  rules:
    - use_primary_constructors
    - empty_container_bodies
''');

    expect(enabledIn(options), {
      'use_primary_constructors',
      'empty_container_bodies',
    });
  });

  test('reads a map of rules with booleans, severities and groups', () {
    final options = write('/app/analysis_options.yaml', '''
linter:
  rules:
    use_primary_constructors: true
    empty_container_bodies: false
    use_declaring_parameters: warning
    unnecessary_type_name_in_constructor: disable
    style:
      prefer_single_quotes: true
      prefer_double_quotes: false
''');

    expect(enabledIn(options), {
      'use_primary_constructors',
      'use_declaring_parameters',
      'prefer_single_quotes',
    });
  });

  test('merges includes with later files taking precedence', () {
    write('/pub/strict/lib/analysis_options.yaml', '''
linter:
  rules:
    - use_primary_constructors
    - empty_container_bodies
    - use_declaring_parameters
''');
    write('/app/shared/analysis_options.yaml', '''
include: package:strict/analysis_options.yaml
linter:
  rules:
    empty_container_bodies: false
''');
    final options = write('/app/analysis_options.yaml', '''
include:
  - shared/analysis_options.yaml
  - ../missing.yaml
linter:
  rules:
    use_declaring_parameters: false
    unnecessary_type_name_in_constructor: true
''');

    expect(enabledIn(options), {
      'use_primary_constructors',
      'unnecessary_type_name_in_constructor',
    });
  });

  test('tolerates include cycles', () {
    write('/app/a.yaml', '''
include: b.yaml
linter:
  rules:
    - use_primary_constructors
''');
    final options = write('/app/b.yaml', '''
include: a.yaml
linter:
  rules:
    - empty_container_bodies
''');

    expect(enabledIn(options), {
      'use_primary_constructors',
      'empty_container_bodies',
    });
  });

  test('ignores files that are missing, malformed or without rules', () {
    expect(enabledIn(provider.getFile(absolute('/none'))), isEmpty);
    expect(enabledIn(write('/app/broken.yaml', 'linter: [')), isEmpty);
    expect(enabledIn(write('/app/scalar.yaml', 'just text')), isEmpty);
    expect(enabledIn(write('/app/empty.yaml', 'linter:\n  rules:\n')), isEmpty);
  });
}
