import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
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
class ConvertRecordIntoNominalType extends DartAssist {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    SourceRange target,
  ) {
    context.registry.addGenericTypeAlias((node) {
      if (!target.intersects(node.sourceRange)) {
        return;
      }

      if (node.type case final RecordTypeAnnotation record) {
        final klass = _classFromRecord(node, record);
        reporter
            .createChangeBuilder(
              message: 'Convert to nominal type',
              priority: 1,
            )
            .addDartFileEdit((builder) {
              builder
                ..importLibraryElement(Uri.parse('package:meta/meta.dart'))
                ..addSimpleReplacement(node.sourceRange, klass)
                ..format(node.sourceRange);
            });
      }
    });
  }

  static String _classFromRecord(
    GenericTypeAlias typeAlias,
    RecordTypeAnnotation record,
  ) {
    final typeParameters = typeParametersString(
      typeAlias.typeParameters?.typeParameters ?? const Iterable.empty(),
      withBounds: true,
    );
    var unnamedCounter = 0;
    final positionals =
        record.positionalFields.map((positional) {
          final name = positional.name?.lexeme ?? 'pos${unnamedCounter++}';
          return (name, positional.type);
        }).toList();

    final named =
        record.namedFields?.fields.map((named) {
          final name = named.name.lexeme;
          return (name, named.type);
        }) ??
        const Iterable.empty();

    final klass = '''
@immutable
${Keyword.CLASS.lexeme} ${typeAlias.name}$typeParameters {
  ${Keyword.CONST.lexeme} ${typeAlias.name}(
${positionals.map((e) => '    ${Keyword.THIS.lexeme}.${e.$1},\n').join()}
${named.isEmpty ? ');' : '{\n${named.map((e) => '    ${e.$2.type?.nullabilitySuffix == NullabilitySuffix.question ? '' : '${Keyword.REQUIRED.lexeme} '}${Keyword.THIS.lexeme}.${e.$1},\n').join()}});'}

${positionals.followedBy(named).map((e) => '  ${Keyword.FINAL.lexeme} ${e.$2.toSource()} ${e.$1};\n').join()}
}
''';

    return klass;
  }
}
