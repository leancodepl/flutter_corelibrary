import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:leancode_lint/config.dart';
import 'package:leancode_lint/src/lints/use_instead_type.dart';
import 'package:leancode_lint/src/type_checker.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem._({
    required this.preferredItem,
    required this.forbiddenItems,
  }) : super(
         name: 'use_design_system_item_${preferredItem.replaceAll(' ', '_')}',
         description: '{0} is forbidden within this design system.',
         correctionMessage:
             'Use the alternative defined in the design system: {1}.',
         severity: .WARNING,
       );

  static Iterable<UseDesignSystemItem> fromConfig(LeanCodeLintConfig config) =>
      config.designSystemItemReplacements.entries.map(
        (entry) => ._(preferredItem: entry.key, forbiddenItems: entry.value),
      );

  @override
  final String preferredItem;
  final List<DesignSystemForbiddenItem> forbiddenItems;

  @override
  TypeChecker getChecker(RuleContext context) => .any([
    for (final forbiddenItem in forbiddenItems)
      if (forbiddenItem.packageName.startsWith('dart:'))
        .fromUrl('${forbiddenItem.packageName}#${forbiddenItem.name}')
      else
        .fromName(forbiddenItem.name, packageName: forbiddenItem.packageName),
  ]);
}
