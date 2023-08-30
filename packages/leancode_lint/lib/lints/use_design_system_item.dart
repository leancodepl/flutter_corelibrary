import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/lints/use_instead_type.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem({
    required String preferredItemName,
    required Iterable<(String, String)> replacements,
  }) : super(
          lintCodeName: '${ruleName}_$preferredItemName',
          replacements: {preferredItemName: replacements.toList()},
        );

  static const ruleName = 'use_design_system_item';

  static Iterable<UseDesignSystemItem> getRulesListFromConfigs(
    CustomLintConfigs configs,
  ) {
    final dsLintOptions = configs.rules[ruleName]?.json ?? {};
    if (dsLintOptions.isEmpty) {
      return const Iterable.empty();
    }

    final designSystemReplacements = dsLintOptions.entries.map(
      (entry) => MapEntry(
        entry.key,
        [
          for (final forbidden in entry.value! as List)
            (
              (forbidden as Map)['from_package'] as String,
              forbidden['instead_of'] as String,
            ),
        ],
      ),
    );

    return designSystemReplacements.map(
      (entry) => UseDesignSystemItem(
        preferredItemName: entry.key,
        replacements: entry.value,
      ),
    );
  }

  @override
  String correctionMessage(String preferredItemName) {
    return 'Use the alternative defined in the design system: $preferredItemName.';
  }

  @override
  String problemMessage(String itemName) {
    return '$itemName is forbidden within this design system.';
  }
}
