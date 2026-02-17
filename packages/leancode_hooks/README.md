<a href="https://leancode.co/?utm_source=github.com&utm_medium=referral&utm_campaign=leancode-hooks" align="center">
  <img alt="leancode_hooks" src="https://github.com/user-attachments/assets/3f593b6f-3abd-481a-b518-0b899a21431a" />
</a>

# leancode_hooks

[Hooks][flutter_hooks] we often use, all gathered in one place for better
discoverability and consistent versioning.

[![leancode_hooks pub.dev badge][pub-badge]][pub-badge-link]
[![][build-badge]][build-badge-link]

## Usage

```dart
import 'package:leancode_hooks/leancode_hooks.dart`;
```

For convenience, this package exports [`package:flutter_hooks`][flutter_hooks]
so you won't have to depend on it.

## Hooks

- [useBloc](lib/src/use_bloc.dart)
- [useBlocListener](lib/src/use_bloc_listener.dart)
- [useBlocState](lib/src/use_bloc_state.dart)
- [useDebounce](lib/src/use_debounce.dart)
- [useDeclarativeTextEditingController](lib/src/use_decarative_text_editing_controller.dart)
- [useDisposable](lib/src/use_disposable.dart)
- [useFocused](lib/src/use_focused.dart)
- [usePostFrameEffect](lib/src/use_post_frame_effect.dart)
- [useStreamListener](lib/src/use_stream_listener.dart)
- [useSyncedTextEditingController](lib/src/use_synced_text_editing_controller.dart)
- [useTapGestureRecognizer](lib/src/use_tap_gesture_recognizer.dart)
- [useThrottle](lib/src/use_throttle.dart)

[flutter_hooks]: https://pub.dev/packages/flutter_hooks
[pub-badge]: https://img.shields.io/pub/v/leancode_hooks
[pub-badge-link]: https://pub.dev/packages/leancode_hooks
[build-badge]: https://img.shields.io/github/actions/workflow/status/leancodepl/flutter_corelibrary/leancode_hooks-test.yml?branch=master
[build-badge-link]: https://github.com/leancodepl/flutter_corelibrary/actions/workflows/leancode_hooks-test.yml
