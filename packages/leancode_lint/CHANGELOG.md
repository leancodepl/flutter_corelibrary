# 1.1.0

- Enable the following lints:
  - `avoid_final_parameters`
  - `conditional_uri_does_not_exist`
  - `literal_only_boolean_expressions`
  - `no_leading_underscores_for_library_prefixes`
  - `no_leading_underscores_for_local_identifiers`
  - `secure_pubspec_urls`
  - `sized_box_shrink_expand`
  - `unnecessary_constructor_name`
  - `unnecessary_late`

# 1.0.2

- Remove dependency on `flutter`
- Update README to differentiate between app and package projects

# 1.0.1+1

- Improve explanation in README on why one might want to add `leancode_lint` as
  a normal dependency instead of dev dependency when using Dart version < 2.14

# 1.0.1

- Disable `prefer_final_parameters` and `library_private_types_in_public_api`
  lints
- Fix warning with `package:flutter_lints/flutter.yaml` not being found

# 1.0.0

- Initial release
