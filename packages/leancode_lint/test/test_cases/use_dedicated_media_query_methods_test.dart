import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/use_dedicated_media_query_methods.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

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
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = /*[0*/MediaQuery.of(context).size/*0]*/.width;
    final padding = /*[1*/MediaQuery.of(context).padding/*1]*/;

    return const SizedBox();
  }
}
''');
  }

  Future<void> test_media_query_maybe_of_context() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    /*[0*/MediaQuery.maybeOf(context)?.size/*0]*/.height;
    /*[1*/MediaQuery.maybeOf(context)?.orientation/*1]*/;
    /*[2*/MediaQuery.maybeOf(context)?.devicePixelRatio/*2]*/;
    /*[3*/MediaQuery.maybeOf(context)?.textScaleFactor/*3]*/;
    /*[4*/MediaQuery.maybeOf(context)?.textScaler/*4]*/;
    /*[5*/MediaQuery.maybeOf(context)?.padding/*5]*/;
    /*[6*/MediaQuery.maybeOf(context)?.viewInsets/*6]*/;
    /*[7*/MediaQuery.maybeOf(context)?.systemGestureInsets/*7]*/.bottom;
    /*[8*/MediaQuery.maybeOf(context)?.alwaysUse24HourFormat/*8]*/;
    /*[9*/MediaQuery.maybeOf(context)?.accessibleNavigation/*9]*/;
    /*[10*/MediaQuery.maybeOf(context)?.invertColors/*10]*/.toString();
    /*[11*/MediaQuery.maybeOf(context)?.highContrast/*11]*/;
    /*[12*/MediaQuery.maybeOf(context)?.onOffSwitchLabels/*12]*/;
    /*[13*/MediaQuery.maybeOf(context)?.disableAnimations/*13]*/;
    /*[14*/MediaQuery.maybeOf(context)?.navigationMode/*14]*/;
    /*[15*/MediaQuery.maybeOf(context)?.gestureSettings/*15]*/;
    /*[16*/MediaQuery.maybeOf(context)?.displayFeatures/*16]*/;
    /*[17*/MediaQuery.maybeOf(context)?.supportsShowingSystemContextMenu/*17]*/;

    return SizedBox();
  }
}
''');
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
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class FooWidget extends StatelessWidget {
  const FooWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: [!MediaQuery.of(context).size!].height * 0.8,
    );
  }
}
''');
  }

  Future<void> test_renamed_context() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';

class FooWithDifferentBuildContextNameWidget extends StatelessWidget {
  const FooWithDifferentBuildContextNameWidget({super.key});

  @override
  Widget build(BuildContext customContextName) {
    final width = /*[0*/MediaQuery.of(customContextName).size/*0]*/.width;
    final padding = /*[1*/MediaQuery.of(customContextName).padding/*1]*/;

    MediaQuery.of(customContextName).runtimeType;

    MediaQuery.of(customContextName);

    return Container(
      height: /*[2*/MediaQuery.of(customContextName).size/*2]*/.height * 0.8,
      width: width,
      padding: padding,
    );
  }
}
''');
  }
}
