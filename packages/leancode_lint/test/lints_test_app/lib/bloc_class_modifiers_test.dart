// for tests
// ignore_for_file: bloc_related_classes_equatable

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
