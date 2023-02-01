# 2.1.0

- Enable the following lints:
  - [`collection_methods_unrelated_type`](https://dart-lang.github.io/linter/lints/collection_methods_unrelated_type.html)
  - [`combinators_ordering`](https://dart-lang.github.io/linter/lints/combinators_ordering.html)
  - [`dangling_library_doc_comments`](https://dart-lang.github.io/linter/lints/dangling_library_doc_comments.html)
  - [`enable_null_safety`](https://dart-lang.github.io/linter/lints/enable_null_safety.html)
  - [`library_annotations`](https://dart-lang.github.io/linter/lints/library_annotations.html)
  - [`unnecessary_library_directive`](https://dart-lang.github.io/linter/lints/unnecessary_library_directive.html)
  - [`use_string_in_part_of_directives`](https://dart-lang.github.io/linter/lints/use_string_in_part_of_directives.html)

# 2.0.0+1

- Fix broken changelog (#90)

# 2.0.0

- **Breaking:** Remove the `unawaited()` function which is provided by Dart
  since 2.14 (#88)
- Disable the `discarded_futures` lint (#87)
- Disable the deprecated `invariant_booleans` lint (#86)

# 1.3.0

- Enable the following lints:
  - [`discarded_futures`](https://dart-lang.github.io/linter/lints/discarded_futures.html)
  - [`unnecessary_to_list_in_spreads`](https://dart-lang.github.io/linter/lints/unnecessary_to_list_in_spreads.html)
  - [`unnecessary_null_aware_operator_on_extension_on_nullable`](https://dart-lang.github.io/linter/lints/unnecessary_null_aware_operator_on_extension_on_nullable.html)

# 1.2.1

- Disable the following lints:
  - [use_build_context_synchronously](https://dart-lang.github.io/linter/lints/use_build_context_synchronously)
  - [library_private_types_in_public_api](https://dart-lang.github.io/linter/lints/library_private_types_in_public_api)

# 1.2.0

- Enable the following lints:
  - [use_super_parameters](https://dart-lang.github.io/linter/lints/use_super_parameters)
  - [use_enums](https://dart-lang.github.io/linter/lints/use_enums)
  - [null_check_on_nullable_type_parameter](https://dart-lang.github.io/linter/lints/null_check_on_nullable_type_parameter.html)
- Bump minimum Dart version to 2.17.

# 1.1.0

- Enable the following lints:
  - [avoid_final_parameters](https://dart-lang.github.io/linter/lints/avoid_final_parameters)
  - [conditional_uri_does_not_exist](https://dart-lang.github.io/linter/lints/conditional_uri_does_not_exist)
  - [literal_only_boolean_expressions](https://dart-lang.github.io/linter/lints/literal_only_boolean_expressions)
  - [no_leading_underscores_for_library_prefixes](https://dart-lang.github.io/linter/lints/no_leading_underscores_for_library_prefixes)
  - [no_leading_underscores_for_local_identifiers](https://dart-lang.github.io/linter/lints/no_leading_underscores_for_local_identifiers)
  - [secure_pubspec_urls](https://dart-lang.github.io/linter/lints/secure_pubspec_urls)
  - [sized_box_shrink_expand](https://dart-lang.github.io/linter/lints/sized_box_shrink_expand)
  - [unnecessary_constructor_name](https://dart-lang.github.io/linter/lints/unnecessary_constructor_name)
  - [unnecessary_late](https://dart-lang.github.io/linter/lints/unnecessary_late)

# 1.0.2

- Remove dependency on `flutter`
- Update README to differentiate between app and package projects

# 1.0.1+1

- Improve explanation in README on why one might want to add `leancode_lint` as
  a normal dependency instead of dev dependency when using Dart version < 2.14

# 1.0.1

- Disable the following lints:
  - [prefer_final_parameters](https://dart-lang.github.io/linter/lints/prefer_final_parameters)
  - [library_private_types_in_public_api](https://dart-lang.github.io/linter/lints/library_private_types_in_public_api)
- Fix warning with `package:flutter_lints/flutter.yaml` not being found

# 1.0.0

- Initial release
