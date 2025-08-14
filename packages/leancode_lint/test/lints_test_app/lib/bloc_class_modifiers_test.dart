// for tests
// ignore_for_file: bloc_related_classes_equatable, bloc_const_constructors

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit's state and presentation event classes not final or sealed are flagged
class Test1Cubit extends Cubit<Test1State>
    with BlocPresentationMixin<Test1State, Test1Event> {
  Test1Cubit() : super(Test1StateInitial());
}

class
// expect_lint: bloc_class_modifiers
Test1State {}

class
// expect_lint: bloc_class_modifiers
Test1StateInitial
    extends Test1State {}

class
// expect_lint: bloc_class_modifiers
Test1Event {}

class
// expect_lint: bloc_class_modifiers
Test1EventFoo
    extends Test1Event {}

///////////////////////////////////////////////////////////////////////

// Bloc's state, event, and presentation event classes not final or sealed are flagged
class Test2Bloc extends Bloc<Test2Event, Test2State>
    with BlocPresentationMixin<Test2State, Test2PresentationEvent> {
  Test2Bloc() : super(Test2StateInitial());
}

class
// expect_lint: bloc_class_modifiers
Test2State {}

class
// expect_lint: bloc_class_modifiers
Test2StateInitial
    extends Test2State {}

class
// expect_lint: bloc_class_modifiers
Test2Event {}

class
// expect_lint: bloc_class_modifiers
Test2EventFoo
    extends Test2Event {}

class
// expect_lint: bloc_class_modifiers
Test2PresentationEvent {}

class
// expect_lint: bloc_class_modifiers
Test2PresentationEventFoo
    extends Test2PresentationEvent {}

///////////////////////////////////////////////////////////////////////

// The abstract modifier is flagged
class Test3Cubit extends Cubit<Test3State> {
  Test3Cubit() : super(Test3StateInitial());
}

abstract class
// expect_lint: bloc_class_modifiers
Test3State {}

final class Test3StateInitial extends Test3State {}

///////////////////////////////////////////////////////////////////////

// Sealed and final classes are not flagged
class Test4Cubit extends Cubit<Test4State>
    with BlocPresentationMixin<Test4State, Test4Event> {
  Test4Cubit() : super(Test4StateInitial());
}

sealed class Test4State {}

final class Test4StateInitial extends Test4State {}

sealed class Test4Event {}

final class Test4EventFoo extends Test4Event {}

///////////////////////////////////////////////////////////////////////

// Bloc's state, event, and presentation event classes not final without descendants are flagged
class Test5Bloc extends Bloc<Test5Event, Test5State>
    with BlocPresentationMixin<Test5State, Test5PresentationEvent> {
  Test5Bloc() : super(const Test5State(1));
}

class
// expect_lint: bloc_class_modifiers
Test5State {
  const Test5State(this.x);

  final int x;
}

class
// expect_lint: bloc_class_modifiers
Test5Event {
  const Test5Event(this.value);

  final int value;
}

class
// expect_lint: bloc_class_modifiers
Test5PresentationEvent {
  const Test5PresentationEvent(this.value);

  final String value;
}

///////////////////////////////////////////////////////////////////////

// Bloc's state, event, and presentation event classes that are final without descendants are not flagged
class Test6Bloc extends Bloc<Test6Event, Test6State>
    with BlocPresentationMixin<Test6State, Test6PresentationEvent> {
  Test6Bloc() : super(const Test6State(1, 2));
}

final class Test6State {
  const Test6State(this.x, this.y);

  final int x;
  final int y;
}

final class Test6Event {
  const Test6Event(this.value);

  final int value;
}

final class Test6PresentationEvent {
  const Test6PresentationEvent(this.value);

  final String value;
}
