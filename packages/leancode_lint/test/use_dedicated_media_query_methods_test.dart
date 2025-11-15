import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_dedicated_media_query_methods.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseDedicatedMediaQueryMethodsTest);
  });
}

@reflectiveTest
class UseDedicatedMediaQueryMethodsTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UseDedicatedMediaQueryMethods();
    super.setUp();

    addMocks([.flutter]);
  }

  Future<void> test_media_query_of_context() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;

    return const SizedBox();
  }
}
''',
      [lint(185, 27), lint(240, 30)],
    );
  }

  Future<void> test_media_query_maybe_of_context() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.maybeOf(context)?.size.height;
    MediaQuery.maybeOf(context)?.orientation;
    MediaQuery.maybeOf(context)?.devicePixelRatio;
    MediaQuery.maybeOf(context)?.textScaleFactor;
    MediaQuery.maybeOf(context)?.textScaler;
    MediaQuery.maybeOf(context)?.padding;
    MediaQuery.maybeOf(context)?.viewInsets;
    MediaQuery.maybeOf(context)?.systemGestureInsets.bottom;
    MediaQuery.maybeOf(context)?.alwaysUse24HourFormat;
    MediaQuery.maybeOf(context)?.accessibleNavigation;
    MediaQuery.maybeOf(context)?.invertColors.toString();
    MediaQuery.maybeOf(context)?.highContrast;
    MediaQuery.maybeOf(context)?.onOffSwitchLabels;
    MediaQuery.maybeOf(context)?.disableAnimations;
    MediaQuery.maybeOf(context)?.navigationMode;
    MediaQuery.maybeOf(context)?.gestureSettings;
    MediaQuery.maybeOf(context)?.displayFeatures;
    MediaQuery.maybeOf(context)?.supportsShowingSystemContextMenu;

    return SizedBox();
  }
}
''',
      [
        lint(171, 33),
        lint(217, 40),
        lint(263, 45),
        lint(314, 44),
        lint(364, 39),
        lint(409, 36),
        lint(451, 39),
        lint(496, 48),
        lint(557, 50),
        lint(613, 49),
        lint(668, 41),
        lint(726, 41),
        lint(773, 46),
        lint(825, 46),
        lint(877, 43),
        lint(926, 44),
        lint(976, 44),
        lint(1026, 61),
      ],
    );
  }

  Future<void> test_non_aspect_access_is_ignored() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).runtimeType;
    MediaQuery.of(context);
    MediaQuery.maybeOf(context);

    return const SizedBox();
  }
}
''');
  }

  Future<void> test_detect_usage_in_constructors() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
    );
  }
}
''',
      [lint(203, 27)],
    );
  }

  Future<void> test_renamed_context() async {
    await assertDiagnostics(
      '''
import 'package:flutter/material.dart';

class FooWithDifferentBuildContextNameWidget extends StatelessWidget {
  const FooWithDifferentBuildContextNameWidget({super.key});

  @override
  Widget build(BuildContext customContextName) {
    final width = MediaQuery.of(customContextName).size.width;
    final padding = MediaQuery.of(customContextName).padding;

    MediaQuery.of(customContextName).runtimeType;

    MediaQuery.of(customContextName);

    return Container(
      height: MediaQuery.of(customContextName).size.height * 0.8,
      width: width,
      padding: padding,
    );
  }
}
''',
      [lint(253, 37), lint(318, 40), lint(487, 37)],
    );
  }
}
