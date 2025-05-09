// for tests
// ignore_for_file: bloc_related_classes_equatable, bloc_class_modifiers

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc-related classes without an explicit unnamed constructor are flagged
class Test1Bloc extends Bloc<Test1Event, Test1State>
    with BlocPresentationMixin<Test1State, Test1PresentationEvent> {
  Test1Bloc() : super(Test1State());
}

class
// expect_lint: bloc_const_constructors
Test1Event {}

class
// expect_lint: bloc_const_constructors
Test1State {}

class
// expect_lint: bloc_const_constructors
Test1PresentationEvent {}

//////////////////////////////////////////////////////////////////////////

// Bloc-related classes with a non-const unnamed constructor are flagged
class Test2Bloc extends Bloc<Test2Event, Test2State>
    with BlocPresentationMixin<Test2State, Test2PresentationEvent> {
  Test2Bloc() : super(Test2State());
}

class Test2Event {
  // expect_lint: bloc_const_constructors
  Test2Event();
}

class Test2State {
  // expect_lint: bloc_const_constructors
  Test2State();
}

class Test2PresentationEvent {
  // expect_lint: bloc_const_constructors
  Test2PresentationEvent();
}

//////////////////////////////////////////////////////////////////////////

// Bloc-related classes with a const unnamed constructor are not flagged
class Test3Bloc extends Bloc<Test3Event, Test3State>
    with BlocPresentationMixin<Test3State, Test3PresentationEvent> {
  Test3Bloc() : super(const Test3State());
}

class Test3Event {
  const Test3Event();
}

class Test3State {
  const Test3State();
}

class Test3PresentationEvent {
  const Test3PresentationEvent();
}
