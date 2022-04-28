import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

T useDebounce<T>(T value, Duration duration) {
  final state = useState(value);

  useEffect(
    () {
      final timer = Timer(duration, () => state.value = value);
      return timer.cancel;
    },
    [value, duration],
  );

  return state.value;
}
