part of '../mock_libraries.dart';

mixin MockFlutterHooks on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('flutter_hooks').addFile('lib/flutter_hooks.dart', '''
import 'package:flutter/material.dart';

void useAutomaticKeepAlive() {}

ValueNotifier<T> useState<T>(T initialData) {}

TextEditingController useTextEditingController() {}

PageController usePageController() {}

class HookWidget extends StatelessWidget {
  const HookWidget({super.key});
}

class HookBuilder extends HookWidget {
  const HookBuilder({required Widget Function(BuildContext context) builder});
}

BuildContext useContext() {}

T useMemoized<T>(
  T Function() valueBuilder, [
  List<Object?> keys = const <Object>[],
]) {}
''');
    super.setUp();
  }
}
