// ignore_for_file: comment_references

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:leancode_lint/custom_lints/use_instead_type.dart';

final class UseDesignSystemItem extends UseInsteadType {
  UseDesignSystemItem({
    required String validType,
    required Iterable<(String, String)> replacements,
  }) : super(
          lintCodeName: 'use_design_system_item_$validType',
          replacements: {validType: replacements.toList()},
        );

  static Iterable<UseDesignSystemItem>? getRulesListFromConfigs(
    CustomLintConfigs configs,
  ) {
    final dsLintOptions = configs.rules['use_design_system_item']?.json ?? {};
    if (dsLintOptions.isEmpty) {
      return null;
    }

    final designSystemReplacements = dsLintOptions.entries.map(
      (entry) => MapEntry(
        entry.key,
        [
          for (final forbidden in entry.value! as List)
            (
              (forbidden as Map)['packageName'] as String,
              forbidden['itemName'] as String,
            ),
        ],
      ),
    );

    return designSystemReplacements.map(
      (entry) => UseDesignSystemItem(
        validType: entry.key,
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
