import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/src/lints/avoid_build_context_in_blocs.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../assert_ranges.dart';
import '../mock_libraries.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidBuildContextInBlocsTest);
  });
}

@reflectiveTest
class AvoidBuildContextInBlocsTest extends AnalysisRuleTest
    with MockBloc, MockFlutter {
  @override
  void setUp() {
    rule = AvoidBuildContextInBlocs();

    super.setUp();
  }

  Future<void> test_passingContextInEvent_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent([this.data]);
  final Object? data;
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  bloc.add([!CounterEvent(context)!]);
}
''');
  }

  Future<void> test_passingContextDirectly_flagged() async {
    const code = '''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  bloc.add(context);
}
''';

    await assertDiagnostics(code, [
      lint(
        code.lastIndexOf('context'),
        'context'.length,
        messageContainsAll: ["Avoid passing a 'BuildContext' to a Bloc."],
        correctionContains:
            "Remove the 'BuildContext' and pass only the data the Bloc needs.",
      ),
    ]);
  }

  Future<void> test_passingContextViaLocalVariable_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent([this.data]);
  final Object? data;
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  final event = CounterEvent(context);
  bloc.add([!event!]);
}
''');
  }

  Future<void> test_passingContextInNestedEvent_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class Inner {
  Inner(this.context);
  final BuildContext context;
}

class CounterEvent {
  CounterEvent(this.inner);
  final Inner inner;
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  bloc.add([!CounterEvent(Inner(context))!]);
}
''');
  }

  Future<void> test_passingContextToConstructor_flagged() async {
    const code = '''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(Object data) : super(0);
}

void f(BuildContext context) {
  CounterCubit(context);
}
''';

    await assertDiagnostics(code, [
      lint(
        code.lastIndexOf('context'),
        'context'.length,
        messageContainsAll: ["Avoid passing a 'BuildContext' to a Cubit."],
        correctionContains:
            "Remove the 'BuildContext' and pass only the data the Cubit needs.",
      ),
    ]);
  }

  Future<void> test_cubitMethodParameter_flagged() async {
    const code = '''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void another(BuildContext context) {}
}
''';

    await assertDiagnostics(code, [
      lint(
        code.lastIndexOf('context'),
        'context'.length,
        messageContainsAll: [
          "Avoid declaring a 'BuildContext' parameter in a Cubit.",
        ],
      ),
    ]);
  }

  Future<void> test_blocMethodParameter_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);

  void another(BuildContext [!context!]) {}
}
''');
  }

  Future<void> test_passingContextToCustomBlocMethod_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);

  void doSomething(BuildContext /*[0*/context/*0]*/) {}
}

void f(CounterBloc bloc, BuildContext context) {
  bloc.doSomething(/*[1*/context/*1]*/);
}
''');
  }

  Future<void> test_cubitConstructorParameter_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(BuildContext [!context!]) : super(0);
}
''');
  }

  Future<void> test_cubitField_flagged() async {
    const code = '''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  late final BuildContext context;
}
''';

    await assertDiagnostics(code, [
      lint(
        code.lastIndexOf('context'),
        'context'.length,
        messageContainsAll: [
          "Avoid declaring a 'BuildContext' field in a Cubit.",
        ],
      ),
    ]);
  }

  Future<void> test_passingParenthesizedLocalVariable_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent(this.context);
  final BuildContext context;
}

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  final event = CounterEvent(context);
  bloc.add([!(event)!]);
}
''');
  }

  Future<void> test_passingCastLocalVariable_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent(this.context);
  final BuildContext context;
}

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  final event = CounterEvent(context);
  bloc.add([!event as Object!]);
}
''');
  }

  Future<void> test_passingNullAssertedLocalVariable_flagged() async {
    await assertDiagnosticsInRanges('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent(this.context);
  final BuildContext context;
}

class CounterBloc extends Bloc<Object, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  final CounterEvent? event = CounterEvent(context) as dynamic;
  bloc.add(/*[0*/event!/*0]*/);
}
''');
  }

  Future<void> test_addWithoutContext_ok() async {
    await assertNoDiagnostics('''
import 'package:bloc/bloc.dart';

class CounterEvent {
  CounterEvent();
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc) {
  bloc.add(CounterEvent());
}
''');
  }

  Future<void> test_passingContextDerivedValue_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';

int deriveFrom(BuildContext context) => 0;

class CounterEvent {
  CounterEvent(this.data);
  final int data;
}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);
}

void f(CounterBloc bloc, BuildContext context) {
  bloc.add(CounterEvent(deriveFrom(context)));
}
''');
  }

  Future<void> test_contextParameterOnNonBloc_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class NotABloc {
  void another(BuildContext context) {}
}
''');
  }

  Future<void> test_methodCallOnNonBloc_ok() async {
    await assertNoDiagnostics('''
import 'package:flutter/material.dart';

class NotABloc {
  void add(Object event) {}
}

class CounterEvent {
  CounterEvent(this.context);
  final BuildContext context;
}

void f(NotABloc notABloc, BuildContext context) {
  notABloc.add(CounterEvent(context));
}
''');
  }
}
