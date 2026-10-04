import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/src/helpers.dart';

/// Converts type aliases of records into classes. This preserves
/// the order and split of positional/named parameters. This results
/// in code where initialization just has to be prefixed with the type name.
///
/// The shape of the class follows the lints enabled for the file, so that the
/// result doesn't immediately trigger any of them:
///
/// - `use_primary_constructors`: the constructor is declared in the class
///   header,
/// - `use_declaring_parameters`: a primary constructor declares the fields in
///   its parameters instead of the class body,
/// - `empty_container_bodies`: a class left without members ends with `;`
///   instead of `{}`,
/// - `unnecessary_type_name_in_constructor`: a constructor in the class body
///   is named `new` instead of repeating the class name.
///
/// **Example**:
///
/// ```dart
/// typedef MyType<T extends Object> = (String, OtherType hello, {int? named1, T named2});
/// ```
///
/// turns into
///
/// ```dart
/// class MyType<T extends Object> {
///   const MyType(
///     this.pos0,
///     this.hello, {
///     this.named1,
///     required this.named2,
///   });
///
///   final String pos0;
///   final OtherType hello;
///   final int? named1;
///   final T named2;
/// }
/// ```
///
/// or, with all of the lints above enabled, into
///
/// ```dart
/// class const MyType<T extends Object>(
///   final String pos0,
///   final OtherType hello, {
///   final int? named1,
///   required final T named2,
/// });
/// ```
class ConvertRecordIntoNominalType({required super.context})
    extends ResolvedCorrectionProducer {
  @override
  AssistKind? get assistKind => const .new(
    'leancode_lint.assist.convertRecordIntoNominalType',
    DartFixKindPriority.standard,
    'Convert to nominal type',
  );

  @override
  CorrectionApplicability get applicability => .singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case GenericTypeAlias(
      :final name,
      :final typeParameters,
      type: final RecordTypeAnnotation record,
    )) {
      final sourceRange = range.node(node);
      final klass = _classFromRecord(name, typeParameters, record, _style());
      await builder.addDartFileEdit(file, (builder) {
        builder
          ..importLibraryElement(.parse('package:meta/meta.dart'))
          ..addSimpleReplacement(sourceRange, klass)
          ..format(sourceRange);
      });
    }
  }

  _ClassStyle _style() {
    // The lints below only ever fire with primary constructors available, and
    // the syntax they ask for doesn't parse without them.
    if (!isEnabled(Feature.primary_constructors)) {
      return const _ClassStyle();
    }
    final lints = enabledLints;
    return _ClassStyle(
      primaryConstructor: lints.contains('use_primary_constructors'),
      declaringParameters: lints.contains('use_declaring_parameters'),
      emptyBodyAsSemicolon: lints.contains('empty_container_bodies'),
      newKeyword: lints.contains('unnecessary_type_name_in_constructor'),
    );
  }

  static String _classFromRecord(
    Token name,
    TypeParameterList? typeParametersList,
    RecordTypeAnnotation record,
    _ClassStyle style,
  ) {
    final typeParameters = typeParametersString(
      typeParametersList?.typeParameters ?? const Iterable.empty(),
      withBounds: true,
    );
    var unnamedCounter = 0;
    final positionals = record.positionalFields.map((positional) {
      final name = positional.name?.lexeme ?? 'pos${unnamedCounter++}';
      return (name, positional.type);
    }).toList();

    final named =
        record.namedFields?.fields.map((named) {
          final name = named.name.lexeme;
          return (name, named.type);
        }).toList() ??
        const <(String, TypeAnnotation)>[];

    // A primary constructor can declare the fields right in its parameters,
    // otherwise they are initialized from the parameters and declared in the
    // class body.
    final declaresFieldsInParameters =
        style.primaryConstructor && style.declaringParameters;
    String parameter((String, TypeAnnotation) field, {required bool isNamed}) {
      final (name, type) = field;
      final required = isNamed && type.type?.nullabilitySuffix != .question
          ? 'required '
          : '';
      final declaration = declaresFieldsInParameters
          ? 'final ${type.toSource()} $name'
          : 'this.$name';
      return '    $required$declaration,\n';
    }

    final parameters =
        '${positionals.map((e) => parameter(e, isNamed: false)).join()}'
        '${named.isEmpty ? '' : '{\n${named.map((e) => parameter(e, isNamed: true)).join()}}'}';

    final fields = declaresFieldsInParameters
        ? ''
        : positionals
              .followedBy(named)
              .map((e) => '  final ${e.$2.toSource()} ${e.$1};\n')
              .join();

    if (style.primaryConstructor) {
      final body = fields.isEmpty
          ? (style.emptyBodyAsSemicolon ? ';' : ' {}')
          : ' {\n$fields}';
      return '''
@immutable
class const $name$typeParameters(
$parameters)$body
''';
    }

    final constructorName = style.newKeyword ? 'new' : name.lexeme;
    return '''
@immutable
class $name$typeParameters {
  const $constructorName(
$parameters);

$fields}
''';
  }
}

/// How the generated class is spelled, as dictated by the enabled lints.
///
/// Defaults to a constructor in the class body, named after the class, with
/// `this.` parameters and fields declared in the body.
class const _ClassStyle({
  /// Declare the constructor in the class header (`use_primary_constructors`).
  final bool primaryConstructor = false,

  /// Declare the fields in the primary constructor's parameters
  /// (`use_declaring_parameters`).
  final bool declaringParameters = false,

  /// End a class with no members with `;` instead of `{}`
  /// (`empty_container_bodies`).
  final bool emptyBodyAsSemicolon = false,

  /// Name a constructor in the class body `new` instead of repeating the class
  /// name (`unnecessary_type_name_in_constructor`).
  final bool newKeyword = false,
});
