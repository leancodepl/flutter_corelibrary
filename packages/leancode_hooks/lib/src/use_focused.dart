import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

bool useFocused(FocusNode focusNode) {
  final focued = useState<bool>(false);

  useEffect(
    () {
      void listener() {
        focued.value = focusNode.hasFocus;
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    },
    [focusNode],
  );

  return focued.value;
}
