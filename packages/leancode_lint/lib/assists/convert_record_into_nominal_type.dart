import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';
import 'package:leancode_lint/helpers.dart';

/// Converts type aliases of records into classes. This preserves
/// the order and split of positional/named parameters. This results
/// in code where initialization just has to be prefixed with the type name.
///
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
class ConvertRecordIntoNominalType extends ResolvedCorrectionProducer {
  ConvertRecordIntoNominalType({required super.context});

  @override
  AssistKind? get assistKind => const AssistKind(
    'leancode.lint.convertRecordIntoNominalType',
    50,
    'Convert to nominal type',
  );

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case GenericTypeAlias(
      :final name,
      :final typeParameters,
      type: final RecordTypeAnnotation record,
    )) {
      final sourceRange = range.node(node);
      final klass = _classFromRecord(name, typeParameters, record);
      await builder.addDartFileEdit(file, (builder) {
        builder
          ..importLibraryElement(Uri.parse('package:meta/meta.dart'))
          ..addSimpleReplacement(sourceRange, klass)
          ..format(sourceRange);
      });
    }
  }

  static String _classFromRecord(
    Token name,
    TypeParameterList? typeParametersList,
    RecordTypeAnnotation record,
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
        }) ??
        const Iterable.empty();

    final klass =
        '''
@immutable
${Keyword.CLASS.lexeme} $name$typeParameters {
  ${Keyword.CONST.lexeme} $name(
${positionals.map((e) => '    ${Keyword.THIS.lexeme}.${e.$1},\n').join()}
${named.isEmpty ? ');' : '{\n${named.map((e) => '    ${e.$2.type?.nullabilitySuffix == NullabilitySuffix.question ? '' : '${Keyword.REQUIRED.lexeme} '}${Keyword.THIS.lexeme}.${e.$1},\n').join()}});'}

${positionals.followedBy(named).map((e) => '  ${Keyword.FINAL.lexeme} ${e.$2.toSource()} ${e.$1};\n').join()}
}
''';

    return klass;
  }
}
