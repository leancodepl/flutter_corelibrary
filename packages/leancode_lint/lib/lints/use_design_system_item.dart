import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/error/error.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/lints/use_instead_type.dart';
import 'package:leancode_lint/type_checker.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem()
    : super(
        name: 'use_design_system_item',
        description: '{0} is forbidden within this design system.',
        correctionMessage:
            'Use the alternative defined in the design system: {1}.',
        severity: DiagnosticSeverity.WARNING,
      );

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
            TypeChecker.any([
              for (final (:name, :packageName) in forbidden)
                if (packageName.startsWith('dart:'))
                  TypeChecker.fromUrl('$packageName#$name')
                else
                  TypeChecker.fromName(name, packageName: packageName),
            ]),
          ),
    ];
  }
}
