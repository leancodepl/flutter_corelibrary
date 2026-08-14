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

/// A widget-agnostic stand-in for lazy, non-widget-returning factories such as
/// a provider's `create`: it takes a `BuildContext`-accepting callback under
/// an arbitrary name and does not itself return a `Widget`.
class Factory extends StatelessWidget {
  const Factory({super.key, required this.make});
  final Object Function(BuildContext context) make;
  @override
  Widget build(BuildContext context) => const SizedBox();
}

/// Same shape as [Factory], but its callback returns a `Widget` — i.e. it is
/// a builder in disguise, under a name that isn't `builder`/`create`.
class WidgetFactory extends StatelessWidget {
  const WidgetFactory({super.key, required this.make});
  final Widget Function(BuildContext context) make;
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

  /// `create` is invoked lazily, once, to construct the provided value — not
  /// on every rebuild — so `read`ing inside it is the intended pattern.
  Future<void> test_providerCreateCallback_ok() async {
    await assertNoDiagnostics(
      _widget('''
    return BlocProvider(
      create: (context) {
        final s = context.read<MyService>();
        return MyCubit();
      },
      child: const SizedBox(),
    );'''),
    );
  }

  /// The exemption is about the callback's return type, not its parameter
  /// name or the enclosing widget's name: any `BuildContext`-taking closure
  /// that doesn't produce a `Widget` is a one-off factory, not a builder.
  Future<void> test_nonWidgetReturningCallback_arbitraryName_ok() async {
    await assertNoDiagnostics(
      _widget('''
    return Factory(make: (context) => context.read<MyService>());'''),
    );
  }

  /// Conversely, a `Widget`-returning callback is still checked even when
  /// it's neither named `builder`/`create` nor declared on a widget with
  /// "Provider" in its name.
  Future<void> test_widgetReturningCallback_arbitraryName_flagged() async {
    await assertDiagnosticsInRanges(
      _widget('''
    return WidgetFactory(
      make: (context) => Consumer(value: context.[!read!]<MyCubit>().state),
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
