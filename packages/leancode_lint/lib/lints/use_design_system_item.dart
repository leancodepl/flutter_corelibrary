import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/lints/use_instead_type.dart';
import 'package:leancode_lint/type_checker.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem()
    : super(
        name: code.name,
        description:
            'Define a project-specific allow/deny list for UI elements. '
            'Forbid using certain platform or package widgets/types directly '
            'and guide developers to the approved design-system alternatives '
            'configured in analysis options.',
        correctionMessage: code.correctionMessage!,
        severity: code.severity,
      );

  static const code = LintCode(
    'use_design_system_item',
    '{0} is forbidden within this design system.',
    correctionMessage: 'Use the alternative defined in the design system: {1}.',
    severity: .WARNING,
  );

  @override
  LintCode get diagnosticCode => code;

  @override
  List<(String, TypeChecker)> getCheckers(RuleContext context) {
    final replacements = LeancodeLintConfig.fromRuleContext(
      context,
    )?.designSystemItemReplacements;

    return [
      if (replacements != null)
        for (final MapEntry(key: preferredItemName, value: forbidden)
            in replacements.entries)
          (
            preferredItemName,
            .any([
              for (final (:name, :packageName) in forbidden)
                if (packageName.startsWith('dart:'))
                  .fromUrl('$packageName#$name')
                else
                  .fromName(name, packageName: packageName),
            ]),
          ),
    ];
  }
}
