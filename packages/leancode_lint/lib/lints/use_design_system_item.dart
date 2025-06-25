// import 'package:custom_lint_builder/custom_lint_builder.dart';
// import 'package:leancode_lint/lints/use_instead_type.dart';
//
// final class UseDesignSystemItemConfig {
//   const UseDesignSystemItemConfig(this.replacements);
//
//   factory UseDesignSystemItemConfig.fromConfig(Map<String, Object?> json) {
//     final replacements = json.entries.map(
//       (entry) => MapEntry(entry.key, [
//         for (final forbidden in entry.value! as List)
//           (
//             name: (forbidden as Map)['instead_of'] as String,
//             packageName: forbidden['from_package'] as String,
//           ),
//       ]),
//     );
//
//     return UseDesignSystemItemConfig(Map.fromEntries(replacements));
//   }
//
//   final Map<String, List<ForbiddenItem>> replacements;
// }
//
// final class UseDesignSystemItem extends UseInsteadType {
//   UseDesignSystemItem({
//     required String preferredItemName,
//     required Iterable<ForbiddenItem> replacements,
//   }) : super(
//          lintCodeName: '${ruleName}_$preferredItemName',
//          replacements: {preferredItemName: replacements.toList()},
//        );
//
//   static const ruleName = 'use_design_system_item';
//
//   static Iterable<UseDesignSystemItem> getRulesListFromConfigs(
//     CustomLintConfigs configs,
//   ) {
//     final config = UseDesignSystemItemConfig.fromConfig(
//       configs.rules[ruleName]?.json ?? {},
//     );
//
//     return config.replacements.entries.map(
//       (entry) => UseDesignSystemItem(
//         preferredItemName: entry.key,
//         replacements: entry.value,
//       ),
//     );
//   }
//
//   @override
//   String correctionMessage(String preferredItemName) {
//     return 'Use the alternative defined in the design system: $preferredItemName.';
//   }
//
//   @override
//   String problemMessage(String itemName) {
//     return '$itemName is forbidden within this design system.';
//   }
// }
