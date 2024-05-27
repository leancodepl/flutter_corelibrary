| Package                                               |                    Documentation                     |                                                       pub                                                       |                                        CI                                        |
|-------------------------------------------------------| :--------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------: |
| [`cqrs`][cqrs-link]                                   |         [Documentation][cqrs-documentation]          |                          [![cqrs pub.dev badge][cqrs-pub-badge]][cqrs-pub-badge-link]                           |                  [![][cqrs-build-badge]][cqrs-build-badge-link]                  |
| [`login_client`][login_client-link]                   |     [Documentation][login_client-documentation]      |              [![login_client pub.dev badge][login_client-pub-badge]][login_client-pub-badge-link]               |          [![][login_client-build-badge]][login_client-build-badge-link]          |
| [`leancode_lint`][leancode_lint-link]                 |     [Documentation][leancode_lint-documentation]     |             [![leancode_lint pub.dev badge][leancode_lint-pub-badge]][leancode_lint-pub-badge-link]             |                                       n/a                                        |
| [`login_client_flutter`][login_client_flutter-link]   | [Documentation][login_client_flutter-documentation]  |  [![login_client_flutter pub.dev badge][login_client_flutter-pub-badge]][login_client_flutter-pub-badge-link]   |  [![][login_client_flutter-build-badge]][login_client_flutter-build-badge-link]  |
| [`override_api_endpoint`][override_api_endpoint-link] | [Documentation][override_api_endpoint-documentation] | [![override_api_endpoint pub.dev badge][override_api_endpoint-pub-badge]][override_api_endpoint-pub-badge-link] | [![][override_api_endpoint-build-badge]][override_api_endpoint-build-badge-link] |
| [`leancode_hooks`][leancode_hooks-link]               |    [Documentation][leancode_hooks-documentation]     |           [![leancode_hooks pub.dev badge][leancode_hooks-pub-badge]][leancode_hooks-pub-badge-link]            |        [![][leancode_hooks-build-badge]][leancode_hooks-build-badge-link]        |
| [`enhanced_gradients`][enhanced_gradients-link]       |  [Documentation][enhanced_gradients-documentation]   |     [![enhanced_gradients pub.dev badge][enhanced_gradients-pub-badge]][enhanced_gradients-pub-badge-link]      |    [![][enhanced_gradients-build-badge]][enhanced_gradients-build-badge-link]    |
| [`leancode_markup`][leancode_markup-link]             |  [Documentation][leancode_markup-documentation]   |     [![leancode_markup pub.dev badge][leancode_markup-pub-badge]][leancode_markup-pub-badge-link]      |    [![][leancode_markup-build-badge]][leancode_markup-build-badge-link]    |
| [`leancode_debug_page`][leancode_debug_page-link]         |  [Documentation][leancode_debug_page-documentation]   |     [![leancode_debug_page pub.dev badge][leancode_debug_page-pub-badge]][leancode_debug_page-pub-badge-link]      |    [![][leancode_debug_page-build-badge]][leancode_debug_page-build-badge-link]    |

## For maintainers

### pub.dev release process

1. Create a pull request with your changes
2. Update `pubspec.yaml` with appropriate package version and add an entry to your package's `CHANGELOG.md`
3. Gather approvals and ensure CI passes
4. Merge
5. Tag your merge commit on `master` with `<package_name>-v<version>` and let the GitHub Actions do the rest.

[cqrs-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/cqrs
[cqrs-documentation]: https://pub.dev/documentation/cqrs/latest/
[cqrs-pub-badge]: https://img.shields.io/pub/v/cqrs
[cqrs-pub-badge-link]: https://pub.dev/packages/cqrs
[cqrs-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/cqrs-test.yml?branch=master
[cqrs-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/cqrs-test.yml
[leancode_lint-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_lint
[leancode_lint-documentation]: https://pub.dev/documentation/leancode_lint/latest/
[leancode_lint-pub-badge]: https://img.shields.io/pub/v/leancode_lint
[leancode_lint-pub-badge-link]: https://pub.dev/packages/leancode_lint
[leancode_hooks-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_hooks
[leancode_hooks-documentation]: https://pub.dev/documentation/leancode_hooks/latest/
[leancode_hooks-pub-badge]: https://img.shields.io/pub/v/leancode_hooks
[leancode_hooks-pub-badge-link]: https://pub.dev/packages/leancode_hooks
[leancode_hooks-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_hooks-test.yml?branch=master
[leancode_hooks-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_hooks-test.yml
[login_client-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/login_client
[login_client-documentation]: https://pub.dev/documentation/login_client/latest/
[login_client-pub-badge]: https://img.shields.io/pub/v/login_client
[login_client-pub-badge-link]: https://pub.dev/packages/login_client
[login_client-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/login_client-test.yml?branch=master
[login_client-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/login_client-test.yml
[login_client_flutter-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/login_client_flutter
[login_client_flutter-documentation]: https://pub.dev/documentation/login_client_flutter/latest/
[login_client_flutter-pub-badge]: https://img.shields.io/pub/v/login_client_flutter
[login_client_flutter-pub-badge-link]: https://pub.dev/packages/login_client_flutter
[login_client_flutter-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/login_client_flutter-test.yml?branch=master
[login_client_flutter-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/login_client_flutter-test.yml
[override_api_endpoint-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/override_api_endpoint
[override_api_endpoint-documentation]: https://pub.dev/documentation/override_api_endpoint/latest/
[override_api_endpoint-pub-badge]: https://img.shields.io/pub/v/override_api_endpoint
[override_api_endpoint-pub-badge-link]: https://pub.dev/packages/override_api_endpoint
[override_api_endpoint-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/override_api_endpoint-test.yml?branch=master
[override_api_endpoint-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/override_api_endpoint-test.yml
[enhanced_gradients-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/enhanced_gradients
[enhanced_gradients-documentation]: https://pub.dev/documentation/enhanced_gradients/latest/
[enhanced_gradients-pub-badge]: https://img.shields.io/pub/v/enhanced_gradients
[enhanced_gradients-pub-badge-link]: https://pub.dev/packages/enhanced_gradients
[enhanced_gradients-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/enhanced_gradients-test.yml?branch=master
[enhanced_gradients-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/enhanced_gradients-test.yml
[leancode_markup-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_markup
[leancode_markup-documentation]: https://pub.dev/documentation/leancode_markup/latest/
[leancode_markup-pub-badge]: https://img.shields.io/pub/v/leancode_markup
[leancode_markup-pub-badge-link]: https://pub.dev/packages/leancode_markup
[leancode_markup-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_markup-test.yml?branch=master
[leancode_markup-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_markup-test.yml
[leancode_debug_page-link]: https://github.com/leancodepl/flutter_corelibrary/tree/master/packages/leancode_debug_page
[leancode_debug_page-documentation]: https://pub.dev/documentation/leancode_debug_page/latest/
[leancode_debug_page-pub-badge]: https://img.shields.io/pub/v/leancode_debug_page
[leancode_debug_page-pub-badge-link]: https://pub.dev/packages/leancode_debug_page
[leancode_debug_page-build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_debug_page-test.yml?branch=master
[leancode_debug_page-build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_debug_page-test.yml
