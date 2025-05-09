// for tests
// ignore_for_file: bloc_related_classes_equatable, bloc_const_constructors

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lints_test_app/bloc_related_class_naming_utils.dart';

// Invalid state name is flagged
class Test1Cubit extends Cubit<WrongStateName> {
  Test1Cubit() : super(WrongStateName());
}

// expect_lint: bloc_related_class_naming
final class WrongStateName {}

//////////////////////////////////////////////////////////////////////////

// Invalid bloc event name is flagged
class Test2Bloc extends Bloc<WrongEventName, Test2State> {
  Test2Bloc() : super(Test2State());
}

// expect_lint: bloc_related_class_naming
final class WrongEventName {}

final class Test2State {}

//////////////////////////////////////////////////////////////////////////

// Invalid presentation event name is flagged
class Test3Bloc extends Bloc<Test3Event, Test3State>
    with BlocPresentationMixin<Test3State, WrongPresentationEventName> {
  Test3Bloc() : super(Test3State());
}

final class Test3Event {}

final class Test3State {}

// expect_lint: bloc_related_class_naming
final class WrongPresentationEventName {}

//////////////////////////////////////////////////////////////////////////

// Invalid names of enums are flagged
class Test4Bloc extends Bloc<WrongEnumEvent, WrongEnumState>
    with BlocPresentationMixin<WrongEnumState, WrongEnumPresentationEvent> {
  Test4Bloc() : super(WrongEnumState.one);
}

// expect_lint: bloc_related_class_naming
enum WrongEnumEvent { one }

// expect_lint: bloc_related_class_naming
enum WrongEnumState { one }

// expect_lint: bloc_related_class_naming
enum WrongEnumPresentationEvent { one }

///////////////////////////////////////////////////////////////////////

// No lint when names are correct
class Correct1Cubit extends Cubit<Correct1State>
    with BlocPresentationMixin<Correct1State, Correct1Event> {
  Correct1Cubit() : super(Correct1State());
}

final class Correct1State {}

final class Correct1Event {}

//////////////////////////////////////////////////////////////////////////

// No lint when names are correct, with event disambiguation
class Correct2Bloc extends Bloc<Correct2Event, Correct2State>
    with BlocPresentationMixin<Correct2State, Correct2PresentationEvent> {
  Correct2Bloc() : super(Correct2State());
}

final class Correct2Event {}

final class Correct2State {}

final class Correct2PresentationEvent {}

//////////////////////////////////////////////////////////////////////////

// No lint when class is from the same package, but another file
class SamePackageBloc extends Bloc<ClassFromSamePackage, ClassFromSamePackage>
    with BlocPresentationMixin<ClassFromSamePackage, ClassFromSamePackage> {
  SamePackageBloc() : super(ClassFromSamePackage());
}

//////////////////////////////////////////////////////////////////////////

// No lint when class is from another package
class AnotherPackageBloc extends Bloc<int, int>
    with BlocPresentationMixin<int, int> {
  AnotherPackageBloc() : super(0);
}
