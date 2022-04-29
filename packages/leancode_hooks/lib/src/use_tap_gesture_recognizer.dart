import 'package:flutter/gestures.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

export 'package:flutter/gestures.dart' show TapGestureRecognizer;

/// Creates a [TapGestureRecognizer] that will be dispose automatically.
TapGestureRecognizer useTapGestureRecognizer(
  TapGestureRecognizer Function() builder, [
  List<Object?> keys = const [],
]) {
  final tapGestureRecognizer = useMemoized(builder, keys);

  useEffect(() => tapGestureRecognizer.dispose, [tapGestureRecognizer]);

  return tapGestureRecognizer;
}
