import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/lints/use_instead_type.dart';
import 'package:leancode_lint/type_checker.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem()
    : super(
        name: code.lowerCaseName,
        description:
            'Define a project-specific allow/deny list for UI elements. '
            'Forbid using certain platform or package widgets/types directly '
            'and guide developers to the approved design-system alternatives '
            'configured in analysis options.',
        correctionMessage: code.correctionMessage!,
        severity: code.severity,
      );

  static const code = LintCode(
    // TODO: use MultiAnalysisRule and specify lint code per item when we can
    // read config before the rule is created.
    // https://github.com/dart-lang/sdk/issues/61755
    'use_design_system_item',
    '{0} is forbidden within this design system.',
    correctionMessage: 'Use the alternative defined in the design system: {1}.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  Map<String, TypeChecker> getCheckers(RuleContext context) {
    final replacements = LeancodeLintConfig.fromRuleContext(
      context,
    ).designSystemItemReplacements;

    return replacements.map(
      (preferredItemName, forbidden) => .new(
        preferredItemName,
        TypeChecker.any([
          for (final (:name, :packageName) in forbidden)
            if (packageName.startsWith('dart:'))
              TypeChecker.fromUrl('$packageName#$name')
            else
              TypeChecker.fromName(name, packageName: packageName),
        ]),
      ),
    );
  }
}
