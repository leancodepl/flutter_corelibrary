import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/test_utilities/test_code_format.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:leancode_lint/src/assists/convert_record_into_nominal_type.dart';
import 'package:leancode_lint/src/sdk_lint_stand_ins.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConvertRecordIntoNominalTypeTest);
    defineReflectiveTests(ConvertRecordIntoNominalTypeLegacyLanguageTest);
  });
}

const _allLints = sdkLintStandIns;

const _source = '''
typedef ^MyType<T extends Object> = (String, OtherType hello, {int? named1, T named2});

class OtherType {}
''';

const _classicClass = '''
import 'package:meta/meta.dart';

@immutable
class MyType<T extends Object> {
  const MyType(this.pos0, this.hello, {this.named1, required this.named2});

  final String pos0;
  final OtherType hello;
  final int? named1;
  final T named2;
}

class OtherType {}
''';

const _newKeywordClass = '''
import 'package:meta/meta.dart';

@immutable
class MyType<T extends Object> {
  const new(this.pos0, this.hello, {this.named1, required this.named2});

  final String pos0;
  final OtherType hello;
  final int? named1;
  final T named2;
}

class OtherType {}
''';

const _primaryConstructorClass = '''
import 'package:meta/meta.dart';

@immutable
class const MyType<T extends Object>(
  this.pos0,
  this.hello, {
  this.named1,
  required this.named2,
}) {
  final String pos0;
  final OtherType hello;
  final int? named1;
  final T named2;
}

class OtherType {}
''';

const _declaringParametersClass = '''
import 'package:meta/meta.dart';

@immutable
class const MyType<T extends Object>(
  final String pos0,
  final OtherType hello, {
  final int? named1,
  required final T named2,
}) {}

class OtherType {}
''';

const _declaringParametersNoBodyClass = '''
import 'package:meta/meta.dart';

@immutable
class const MyType<T extends Object>(
  final String pos0,
  final OtherType hello, {
  final int? named1,
  required final T named2,
});

class OtherType {}
''';

@reflectiveTest
class ConvertRecordIntoNominalTypeTest() extends _AssistTest {
  Future<void> test_noLints() async {
    await assertAssist(_source, _classicClass);
  }

  Future<void> test_unnecessaryTypeNameInConstructor() async {
    createAnalysisOptionsFile(lints: ['unnecessary_type_name_in_constructor']);
    await assertAssist(_source, _newKeywordClass);
  }

  Future<void> test_usePrimaryConstructors() async {
    createAnalysisOptionsFile(lints: ['use_primary_constructors']);
    await assertAssist(_source, _primaryConstructorClass);
  }

  Future<void> test_usePrimaryConstructors_emptyContainerBodies() async {
    // The body still holds the fields, so there is nothing to shorten.
    createAnalysisOptionsFile(
      lints: ['use_primary_constructors', 'empty_container_bodies'],
    );
    await assertAssist(_source, _primaryConstructorClass);
  }

  Future<void> test_usePrimaryConstructors_useDeclaringParameters() async {
    createAnalysisOptionsFile(
      lints: ['use_primary_constructors', 'use_declaring_parameters'],
    );
    await assertAssist(_source, _declaringParametersClass);
  }

  Future<void> test_allLints() async {
    createAnalysisOptionsFile(lints: _allLints);
    await assertAssist(_source, _declaringParametersNoBodyClass);
  }

  Future<void> test_useDeclaringParameters_withoutPrimaryConstructor() async {
    // Only primary constructors have declaring parameters.
    createAnalysisOptionsFile(
      lints: ['use_declaring_parameters', 'empty_container_bodies'],
    );
    await assertAssist(_source, _classicClass);
  }

  Future<void> test_allLints_emptyRecord() async {
    createAnalysisOptionsFile(lints: _allLints);
    await assertAssist('typedef ^Unit = ();\n', '''
import 'package:meta/meta.dart';

@immutable
class const Unit();
''');
  }

  Future<void> test_usePrimaryConstructors_emptyRecord() async {
    createAnalysisOptionsFile(lints: ['use_primary_constructors']);
    await assertAssist('typedef ^Unit = ();\n', '''
import 'package:meta/meta.dart';

@immutable
class const Unit() {}
''');
  }

  Future<void> test_lintsEnabledThroughPackageInclude() async {
    _writeLintsPackage();
    createAnalysisOptionsFile(
      includes: ['package:strict_lints/analysis_options.yaml'],
    );
    await assertAssist(_source, _declaringParametersNoBodyClass);
  }

  Future<void> test_includedLintDisabledLocally() async {
    _writeLintsPackage();
    writeAnalysisOptionsFile('''
include: package:strict_lints/analysis_options.yaml

linter:
  rules:
    use_primary_constructors: false
''');
    await assertAssist(_source, _newKeywordClass);
  }

  Future<void> test_nestedOptionsFile() async {
    createAnalysisOptionsFile(lints: _allLints);
    // A nested options file stands on its own, it doesn't inherit the
    // enclosing one.
    newFile('$testPackageLibPath/nested/analysis_options.yaml', '''
linter:
  rules:
    - use_primary_constructors
''');
    await assertAssist(
      _source,
      _primaryConstructorClass,
      path: '$testPackageLibPath/nested/test.dart',
    );
  }

  /// Adds a `strict_lints` package whose options file enables all the lints
  /// the assist cares about.
  void _writeLintsPackage() {
    newPackage('strict_lints').addFile('lib/analysis_options.yaml', '''
linter:
  rules:
${_allLints.map((lint) => '    - $lint\n').join()}''');
    writeTestPackageConfig2();
  }
}

/// Without primary constructors in the language, none of the lints apply and
/// their syntax isn't available.
@reflectiveTest
class ConvertRecordIntoNominalTypeLegacyLanguageTest() extends _AssistTest {
  @override
  String? get testPackageLanguageVersion => '3.12';

  Future<void> test_allLints() async {
    createAnalysisOptionsFile(lints: _allLints);
    await assertAssist(_source, _classicClass);
  }
}

abstract class _AssistTest() extends PubPackageResolutionTest {
  @override
  bool get addMetaPackageDep => true;

  @override
  void setUp() {
    registerSdkLintStandIns();
    super.setUp();
  }

  /// Applies the assist at the `^` marker in [content] and asserts that the
  /// file then reads [expected].
  Future<void> assertAssist(
    String content,
    String expected, {
    String? path,
  }) async {
    final code = TestCode.parse(content);
    final file = newFile(path ?? testFilePath, code.code);
    final unit = await resolveFile(file.path);
    final library = await unit.session.getResolvedLibrary(
      file.path,
    ) as ResolvedLibraryResult;
    final producer = ConvertRecordIntoNominalType(
      context: CorrectionProducerContext.createResolved(
        libraryResult: library,
        unitResult: unit,
        selectionOffset: code.position.offset,
      ),
    );

    final builder = ChangeBuilder(session: unit.session);
    await producer.compute(builder);

    final edits = builder.sourceChange.edits.single.edits;
    expect(SourceEdit.applySequence(code.code, edits), expected);
  }
}
