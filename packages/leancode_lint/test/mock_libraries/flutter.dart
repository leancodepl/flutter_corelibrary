part of '../mock_libraries.dart';

mixin MockFlutter on AnalysisRuleTest {
  @override
  bool get addFlutterPackageDep => true;

  @override
  void setUp() {
    super.setUp();

    final flutterRootPath = addFlutter().parent.path;

    appendFile(
      join(flutterRootPath, 'lib', 'src', 'widgets', 'basic.dart'),
      _basicMock,
    );

    appendFile(
      join(flutterRootPath, 'lib', 'src', 'widgets', 'sliver.dart'),
      _sliverMock,
    );

    newFile(
      join(flutterRootPath, 'lib', 'src', 'widgets', 'media_query.dart'),
      _mediaQueryMock,
    );

    newFile(
      join(flutterRootPath, 'lib', 'src', 'widgets', 'scroll_delegate.dart'),
      _scrollDelegateMock,
    );

    newFile(
      join(flutterRootPath, 'lib', 'src', 'widgets', 'page_view.dart'),
      _pageViewMock,
    );

    newFile(
      join(flutterRootPath, 'lib', 'src', 'painting', 'text_span.dart'),
      _textSpanMock,
    );

    appendFile(join(flutterRootPath, 'lib', 'widgets.dart'), '''
export 'src/widgets/media_query.dart';
export 'src/widgets/scroll_delegate.dart';
export 'src/widgets/page_view.dart';
export 'src/painting/text_span.dart';
''');

    newFile(
      join(flutterRootPath, 'lib', 'src', 'foundation', 'change_notifier.dart'),
      _changeNotifierMock,
    );

    newFile(
      join(flutterRootPath, 'lib', 'src', 'material', 'icon_button.dart'),
      _iconButtonMock,
    );

    appendFile(join(flutterRootPath, 'lib', 'material.dart'), '''
export 'src/material/icon_button.dart';
''');

    appendFile(join(flutterRootPath, 'lib', 'foundation.dart'), '''
export 'src/foundation/change_notifier.dart';
''');
  }
}

const _mediaQueryMock = '''
class MediaQuery extends Widget {
  static MediaQueryData of(BuildContext context) {}
  static MediaQueryData? maybeOf(BuildContext context) {}
}

class MediaQueryData {
  final Size size;
  final Orientation orientation;
  final double devicePixelRatio;
  final double textScaleFactor;
  final TextScaler textScaler;
  final Brightness platformBrightness;
  final EdgeInsets viewInsets;
  final EdgeInsets padding;
  final EdgeInsets viewPadding;
  final EdgeInsets systemGestureInsets;
  final bool alwaysUse24HourFormat;
  final bool accessibleNavigation;
  final bool invertColors;
  final bool highContrast;
  final bool onOffSwitchLabels;
  final bool disableAnimations;
  final bool boldText;
  final bool supportsAnnounce;
  final NavigationMode navigationMode;
  final DeviceGestureSettings gestureSettings;
  final List<ui.DisplayFeature> displayFeatures;
  final bool supportsShowingSystemContextMenu;
}
''';

const _basicMock = '''
class Wrap extends Widget {
  const Wrap({super.key, this.children = const []});
  final List<Widget> children;
}

class RichText extends Widget {
  const RichText({super.key, required this.text});
  final InlineSpan text;
}

class Semantics extends Widget {
  const Semantics({
    super.key,
    this.child,
    bool? button,
    String? label,
    String? value,
    String? increasedValue,
    String? decreasedValue,
    String? hint,
    String? tooltip,
    String? onTapHint,
    String? onLongPressHint,
    VoidCallback? onTap,
  });
  const Semantics.fromProperties({
    super.key,
    this.child,
    required SemanticsProperties properties,
  });
  final Widget? child;
}

class SemanticsProperties {
  const SemanticsProperties({
    String? label,
    String? value,
    String? hint,
    String? tooltip,
    SemanticsHintOverrides? hintOverrides,
  });
}

class SemanticsHintOverrides {
  const SemanticsHintOverrides({String? onTapHint, String? onLongPressHint});
}

class CustomSemanticsAction {
  const CustomSemanticsAction({required String label});
}
''';

const _iconButtonMock = '''
import 'package:flutter/widgets.dart';

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    required VoidCallback? onPressed,
    String? tooltip,
    Widget? selectedIcon,
    required Widget icon,
  });
  const IconButton.filled({
    super.key,
    required VoidCallback? onPressed,
    String? tooltip,
    required Widget icon,
  });
}

class FloatingActionButton extends StatelessWidget {
  const FloatingActionButton({
    super.key,
    Widget? child,
    String? tooltip,
    required VoidCallback? onPressed,
  });
  const FloatingActionButton.extended({
    super.key,
    String? tooltip,
    required VoidCallback? onPressed,
    Widget? icon,
    required Widget label,
  });
}

class Tooltip extends StatelessWidget {
  const Tooltip({super.key, String? message, Widget? child});
}
''';

const _sliverMock = '''
class SliverCrossAxisGroup extends Widget {
  const SliverCrossAxisGroup({super.key, required this.slivers});
  final List<Widget> slivers;
}

class SliverMainAxisGroup extends Widget {
  const SliverMainAxisGroup({super.key, required this.slivers});
  final List<Widget> slivers;
}
''';

const _scrollDelegateMock = '''
class SliverChildListDelegate {
  SliverChildListDelegate(this.children);
  final List<Widget> children;
}
''';

const _pageViewMock = '''
import 'package:flutter/widgets.dart';

class PageView extends Widget {
  PageView({super.key, this.controller, this.children = const []});
  final PageController? controller;
  final List<Widget> children;
}

class PageController {
  PageController({this.initialPage = 0});
  final int initialPage;
}
''';

const _textSpanMock = '''
class InlineSpan {}

class TextSpan extends InlineSpan {
  const TextSpan({this.text, this.children});
  final String? text;
  final List<InlineSpan>? children;
}
''';

const _changeNotifierMock = '''
mixin class ChangeNotifier {
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

abstract class Listenable {
  const Listenable();
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

abstract class ValueListenable<T> extends Listenable {
  const ValueListenable();
  T get value;
}

class ValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  ValueNotifier(this._value);
  final T _value;
  @override
  T get value => _value;
}
''';
