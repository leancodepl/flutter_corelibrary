# leancode_hooks

[Hooks][flutter-hooks] we often use, all gathered in one place for better
discoverability and consistent versioning.

[![leancode_hooks pub.dev badge][pub-badge]][pub-badge-link]

[pub-badge]: https://img.shields.io/pub/v/leancode_hooks
[pub-badge-link]: https://pub.dev/packages/leancode_hooks

## Usage

```dart
import 'package:leancode_hooks/leancode_hooks.dart`;
```

For convenience, this package exports [`package:flutter_hooks`][flutter_hooks]
so you won't have to depend on it.

## Hooks

- [useBloc](lib/src/use_bloc.dart)
- [useDebounce](lib/src/use_debounce.dart)
- [useDeclarativeTextEditingController](lib/src/use_decarative_text_editing_controller.dart)
- [useFocused](lib/src/use_focused.dart)
- [usePostFrameEffect](lib/src/use_post_frame_effect.dart)
- [useStreamListener](lib/src/use_stream_listener.dart)
- [useSyncedTextEditingController](lib/src/use_synced_text_editing_controller.dart)
- [useTapGestureRecognizer](lib/src/use_tap_gesture_recognizer.dart)
- [useThrottle](lib/src/use_throttle.dart)

[flutter_hooks]: https://pub.dev/packages/flutter_hooks
