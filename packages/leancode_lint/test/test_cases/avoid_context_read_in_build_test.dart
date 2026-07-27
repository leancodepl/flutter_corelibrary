import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/avoid_context_read_in_build.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidContextReadInBuildTest);
  });
}

/// Wraps [buildBody] (the contents of a widget's `build` method) in a source
/// file with the helpers the test cases reference.
String _widget(String buildBody) =>
    '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);
  void doThing() {}
}

class MyService {}

class Consumer extends StatelessWidget {
  const Consumer({super.key, this.value});
  final Object? value;
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class Button extends StatelessWidget {
  const Button({super.key, this.onTap});
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
$buildBody
  }
}
''';

@reflectiveTest
class AvoidContextReadInBuildTest extends AnalysisRuleTest
    with MockFlutter, MockBloc, MockFlutterBloc {
  @override
  void setUp() {
    rule = AvoidContextReadInBuild();

    super.setUp();
  }

  Future<void> test_stateGetter_intoVariable_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    final s = context.[!read!]<MyCubit>().state;
    return Consumer(value: s);'''),
    );
  }

  Future<void> test_stateGetter_inline_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return Consumer(value: context.[!read!]<MyCubit>().state);'''),
    );
  }

  Future<void> test_plainValue_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return Consumer(value: context.[!read!]<int>());'''),
    );
  }

  Future<void> test_insideBuilder_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return Builder(
      builder: (context) => Consumer(value: context.[!read!]<MyCubit>().state),
    );'''),
    );
  }

  Future<void> test_methodReceiver_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    context.[!read!]<MyCubit>().doThing();
    return const SizedBox();'''),
    );
  }

  Future<void> test_blocObjectReference_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return Consumer(value: context.[!read!]<MyCubit>());'''),
    );
  }

  /// The tear-off evaluates the read during build, unlike
  /// [test_deferredCallback_ok] which defers it until the tap.
  Future<void> test_methodTearOff_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return Button(onTap: context.[!read!]<MyCubit>().doThing);'''),
    );
  }

  Future<void> test_serviceReference_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    final s = context.[!read!]<MyService>();
    return Consumer(value: s);'''),
    );
  }

  Future<void> test_deferredCallback_ok() async {
    await assertNoDiagnostics(
      _widget('''
    return Button(onTap: () => context.read<MyCubit>().doThing());'''),
    );
  }

  Future<void> test_deferredCallbackInsideBuilder_ok() async {
    await assertNoDiagnostics(
      _widget('''
    return Builder(
      builder: (context) =>
          Button(onTap: () => context.read<MyCubit>().doThing()),
    );'''),
    );
  }

  Future<void> test_watch_ok() async {
    await assertNoDiagnostics(
      _widget('''
    return Consumer(value: context.watch<MyCubit>().state);'''),
    );
  }

  Future<void> test_readOutsideWidget_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyCubit extends Cubit<int> {
  MyCubit() : super(0);
}

class NotAWidget {
  NotAWidget(this.context);
  final BuildContext context;

  int build() => context.read<MyCubit>().state;
}
''');
  }
}
