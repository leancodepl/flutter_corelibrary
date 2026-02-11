# 20.0.2

- Fix: Support entries with spaces in `use_design_system_item`.

# 20.0.1

- Add the `example/` directory with default and custom configuration examples.

# 20.0.0

- **Breaking:** Migrate from custom_lint to the analysis server plugin.
  See the [README](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint) for instructions on how to use the plugin.
- **Breaking:** Require `analyzer` ^10.0.0.
- **Breaking:** Require Dart 3.10.
- Add configurable names for the `catch_parameter_names` rule. Defaults remain `err` and `st`.
- Move implementation files into the `src` directory.

# 19.0.1

- fix: Make `prefer_center_over_align` not crash in non-Flutter packages.

# 19.0.0

- Support `analyzer` 8.1.0
- Support `custom_lint_builder` 0.8.1
- Enable the following lints:
  - [`prefer_center_over_align`](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint#prefer_center_over_align)

# 18.0.0

- chore: Refactor lint codes to use built-in positional parameters.
- Support Flutter 3.35 and Dart 3.9
- Enable the following lints:
  - [`switch_on_type`](https://dart.dev/tools/linter-rules/switch_on_type)
  - [`unnecessary_unawaited`](https://dart.dev/tools/linter-rules/unnecessary_unawaited)
  - [`use_dedicated_media_query_methods`](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint#use_dedicated_media_query_methods)
  - [`use_align`](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint#use_align)
  - [`use_padding`](https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint#use_padding)
- Disable the [`omit_obvious_property_types`](https://dart.dev/tools/linter-rules/omit_obvious_property_types) lint due to conflict with [`type_annotate_public_apis`](https://dart.dev/tools/linter-rules/type_annotate_public_apis) ([Dart SDK issue #60642](https://github.com/dart-lang/sdk/issues/60642))

# 17.0.0

- Support Flutter 3.32 and Dart 3.8
- Enable the following lints:
  - [`unnecessary_ignore`](https://dart.dev/tools/linter-rules/unnecessary_ignore)
  - [`use_null_aware_elements`](https://dart.dev/tools/linter-rules/use_null_aware_elements)

# 16.0.0

- Support Flutter 3.29 and Dart 3.7
- Enable the following lints:
  - [`strict_top_level_inference`](https://dart.dev/tools/linter-rules/strict_top_level_inference)
  - [`unnecessary_underscores`](https://dart.dev/tools/linter-rules/unnecessary_underscores)
  - [`omit_obvious_property_types`](https://dart.dev/tools/linter-rules/omit_obvious_property_types)
  - [`unnecessary_async`](https://dart.dev/tools/linter-rules/unnecessary_async)
  - [`unsafe_variance`](https://dart.dev/tools/linter-rules/unsafe_variance)
- Remove the following lints which have been removed from Dart:
  - [`package_api_docs`](https://dart.dev/tools/linter-rules/package_api_docs)
  - [`unsafe_html`](https://dart.dev/tools/linter-rules/unsafe_html)
- Disable the [`require_trailing_commas`](https://dart.dev/tools/linter-rules/require_trailing_commas) lint as it conflicts with Dart 3.7 formatter (https://github.com/dart-lang/sdk/issues/60119).

# 15.1.0

- Support `analyzer` 7.0.0

# 15.0.0

- Enable the following lints:
  - [`use_truncating_division`](https://dart.dev/tools/linter-rules/use_truncating_division)
  - [`avoid_futureor_void`](https://dart.dev/tools/linter-rules/avoid_futureor_void)
  - [`omit_obvious_local_variable_types`](https://dart.dev/tools/linter-rules/omit_obvious_local_variable_types)
- Disable the [`omit_local_variable_types`](https://dart.dev/tools/linter-rules/omit_local_variable_types)

# 14.4.0

- Support Flutter 3.27 and Dart 3.6

# 14.3.0

- Support `custom_lint` 0.7.0

# 14.2.0

- Remove deprecated `division_optimization` hint

# 14.1.0

- Allow usage of a forbidden item in a `hide` combinator in `use_design_system_item`

# 14.0.0

- Bump minimum Dart version to 3.5
- Enable the following lints:
  - [`unintended_html_in_doc_comment`](https://dart.dev/lints/unintended_html_in_doc_comment)
  - [`invalid_runtime_check_with_js_interop_types`](https://dart.dev/lints/invalid_runtime_check_with_js_interop_types)
  - [`document_ignores`](https://dart.dev/lints/document_ignores)
- Disable the [`avoid_positional_boolean_parameters`](https://dart.dev/tools/linter-rules/avoid_positional_boolean_parameters) lint

# 13.0.0

- Bump minimum Dart version to 3.4
- Enable the following lints:
  - [`unnecessary_library_name`](https://dart.dev/tools/linter-rules/unnecessary_library_name)
  - [`missing_code_block_language_in_doc_comment`](https://dart.dev/tools/linter-rules/missing_code_block_language_in_doc_comment)

# 12.1.0

- Treat `HookWidget` as a new hook context. This should remove some false positives in `avoid_conditional_hooks` and catch new cases in `hook_widget_does_not_use_hooks`.

# 12.0.0

- Remove deprecated `import_of_legacy_library_into_null_safe` error code

# 11.0.0

- Treat `HookConsumer` and `HookConsumerWidget` from `package:hooks_riverpod` as hook widgets

# 10.0.0

- Bump `custom_lint_builder` dependency to 0.6.2

# 9.0.0

- Disable lints deprecated in Dart 3.3.0
- Bump minimum Dart version to 3.3
- Enable custom lint `avoid_single_child_in_multi_child_widgets` for `Column`, `Row`, `Flex`, `Wrap`, `SliverList`, `MultiSliver`, `SliverChildListDelegate`, `SliverMainAxisGroup`, and `SliverCrossAxisGroup`
- Fix `avoid_conditional_hooks` false positive

# 8.0.0

- Enable the following lints:
  - [`annotate_redeclares`](https://dart.dev/tools/linter-rules/annotate_redeclares)
  - [`use_build_context_synchronously`](https://dart.dev/tools/linter-rules/use_build_context_synchronously)

# 7.0.0+1

- Change package description on pub.dev and in README

# 7.0.0

- Implement LeanCode custom lints

# 6.0.0

- Enable the following lints:
  - [`no_self_assignments`](https://dart.dev/tools/linter-rules/no_self_assignments)
  - [`no_wildcard_variable_uses`](https://dart.dev/tools/linter-rules/no_wildcard_variable_uses)
- Remove deprecated rules `iterable_contains_unrelated_type` and `list_remove_unrelated_type`
- Bump minimum Dart version to 3.1

# 5.0.0

- Elevate level of all infos to warning except for:
  - [`deprecated_member_use_from_same_package`](https://dart.dev/tools/linter-rules/deprecated_member_use_from_same_package)
  - [`deprecated_export_use`](https://dart.dev/tools/diagnostic-messages#deprecated_export_use)
  - [`deprecated_member_use`](https://dart.dev/tools/diagnostic-messages#deprecated_member_use)
  - `hack`
  - `todo`
  - `undone`

# 4.0.0+2

- Add `analysis` and `lints` topics to pubspec

# 4.0.0+1

- Remove lint [`library_private_types_in_public_api`](https://dart.dev/tools/linter-rules/library_private_types_in_public_api) which was accidentally enabled

# 4.0.0

- Enable the following lints:
  - [`implicit_reopen`](https://dart.dev/tools/linter-rules/implicit_reopen)
  - [`unnecessary_breaks`](https://dart.dev/tools/linter-rules/unnecessary_breaks)
  - [`type_literal_in_constant_pattern`](https://dart.dev/tools/linter-rules/type_literal_in_constant_pattern)
  - [`invalid_case_patterns`](https://dart.dev/tools/linter-rules/invalid_case_patterns)
  - [`deprecated_member_use_from_same_package`](https://dart.dev/tools/linter-rules/deprecated_member_use_from_same_package)
- Remove the deprecated lint [`enable_null_safety`](https://dart.dev/tools/linter-rules/enable_null_safety)
- Bump minimum Dart version to 3.0
- Remove dependence on `flutter_lints`

# 3.0.0

- Migrate from `analyzer.strong-mode.{implicit-casts,implicit-dynamic}` to `analyzer.language.{strict-casts,strict-inference,strict-raw-types}` which might report new warnings

# 2.1.0

- Enable the following lints:
  - [`collection_methods_unrelated_type`](https://dart.dev/tools/linter-rules/collection_methods_unrelated_type)
  - [`combinators_ordering`](https://dart.dev/tools/linter-rules/combinators_ordering)
  - [`dangling_library_doc_comments`](https://dart.dev/tools/linter-rules/dangling_library_doc_comments)
  - [`enable_null_safety`](https://dart.dev/tools/linter-rules/enable_null_safety)
  - [`library_annotations`](https://dart.dev/tools/linter-rules/library_annotations)
  - [`unnecessary_library_directive`](https://dart.dev/tools/linter-rules/unnecessary_library_directive)
  - [`use_string_in_part_of_directives`](https://dart.dev/tools/linter-rules/use_string_in_part_of_directives)

# 2.0.0+1

- Fix broken changelog (#90)

# 2.0.0

- **Breaking:** Remove the `unawaited()` function which is provided by Dart
  since 2.14 (#88)
- Disable the `discarded_futures` lint (#87)
- Disable the deprecated `invariant_booleans` lint (#86)

# 1.3.0

- Enable the following lints:
  - [`discarded_futures`](https://dart.dev/tools/linter-rules/discarded_futures)
  - [`unnecessary_to_list_in_spreads`](https://dart.dev/tools/linter-rules/unnecessary_to_list_in_spreads)
  - [`unnecessary_null_aware_operator_on_extension_on_nullable`](https://dart.dev/tools/linter-rules/unnecessary_null_aware_operator_on_extension_on_nullable)

# 1.2.1

- Disable the following lints:
  - [use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously)
  - [library_private_types_in_public_api](https://dart.dev/tools/linter-rules/library_private_types_in_public_api)

# 1.2.0

- Enable the following lints:
  - [use_super_parameters](https://dart.dev/tools/linter-rules/use_super_parameters)
  - [use_enums](https://dart.dev/tools/linter-rules/use_enums)
  - [null_check_on_nullable_type_parameter](https://dart.dev/tools/linter-rules/null_check_on_nullable_type_parameter)
- Bump minimum Dart version to 2.17.

# 1.1.0

- Enable the following lints:
  - [avoid_final_parameters](https://dart.dev/tools/linter-rules/avoid_final_parameters)
  - [conditional_uri_does_not_exist](https://dart.dev/tools/linter-rules/conditional_uri_does_not_exist)
  - [literal_only_boolean_expressions](https://dart.dev/tools/linter-rules/literal_only_boolean_expressions)
  - [no_leading_underscores_for_library_prefixes](https://dart.dev/tools/linter-rules/no_leading_underscores_for_library_prefixes)
  - [no_leading_underscores_for_local_identifiers](https://dart.dev/tools/linter-rules/no_leading_underscores_for_local_identifiers)
  - [secure_pubspec_urls](https://dart.dev/tools/linter-rules/secure_pubspec_urls)
  - [sized_box_shrink_expand](https://dart.dev/tools/linter-rules/sized_box_shrink_expand)
  - [unnecessary_constructor_name](https://dart.dev/tools/linter-rules/unnecessary_constructor_name)
  - [unnecessary_late](https://dart.dev/tools/linter-rules/unnecessary_late)

# 1.0.2

- Remove dependency on `flutter`
- Update README to differentiate between app and package projects

# 1.0.1+1

- Improve explanation in README on why one might want to add `leancode_lint` as
  a normal dependency instead of dev dependency when using Dart version < 2.14

# 1.0.1

- Disable the following lints:
  - [prefer_final_parameters](https://dart.dev/tools/linter-rules/prefer_final_parameters)
  - [library_private_types_in_public_api](https://dart.dev/tools/linter-rules/library_private_types_in_public_api)
- Fix warning with `package:flutter_lints/flutter.yaml` not being found

# 1.0.0

- Initial release
