# 0.1.1

- Bump `bloc` to `9.0.0`.
- Bump `flutter_hooks` to `0.20.5`.

# 0.1.0

- **Breaking**: Replace all `keys` that were declared as [optional positional parameter](https://dart.dev/language/functions#optional-positional-parameters) with a [named parameter](https://dart.dev/language/functions#named-parameters) that defaults to `const List<Object?>[]`. Affected hooks: `useBloc`, `usePostFrameEffect`, `useTapGestureRecognizer`.
- Add `useDisposable` hook.
- Bump `leancode_lint` dev dependency to `12.0.0`.
- Bump `custom_lint` dev dependency to `0.6.4`.

# 0.0.6

- Bump minimum Dart version to 3.0
- Bump minimum Flutter version to 3.10.0
- Bump minimum flutter_hooks version to 0.20.1

# 0.0.5

- Add `useBlocListener` hook.
- Add `useBloc` hook.

# 0.0.4

- Make `usePostFrameEffect` accept nullable keys.

# 0.0.3+1

- Fix build badge in README.

# 0.0.3

- Add tests for `useThrottle`
- Fix broken links in README and CHANGELOG.

# 0.0.2

- Improve README.
- Delete `useGoogleMapController` hook. You can view it
  [here](https://github.com/leancodepl/flutter_corelibrary/blob/leancode_hooks-v0.0.1/packages/leancode_hooks/lib/src/use_google_map_controller.dart).

# 0.0.1

- Initial release
