import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lints_test_app/bloc_related_class_naming_utils.dart';

// region Incorrect blocs

// Test for invalid state name
class Test1Cubit extends Cubit<WrongStateName> {
  Test1Cubit() : super(WrongStateName());
}

// expect_lint: bloc_related_class_naming
class WrongStateName {}

// Test for invalid event name
class Test2Bloc extends Bloc<WrongEventName, Test2State> {
  Test2Bloc() : super(Test2State());
}

// expect_lint: bloc_related_class_naming
class WrongEventName {}

class Test2State {}

// Test for invalid presentation event name
class Test3Bloc extends Bloc<Test3Event, Test3State>
    with BlocPresentationMixin<Test3State, WrongPresentationEventName> {
  Test3Bloc() : super(Test3State());
}

class Test3Event {}

class Test3State {}

// expect_lint: bloc_related_class_naming
class WrongPresentationEventName {}

// Invalid names detected for enums
class Test4Cubit extends Bloc<WrongEnumEvent, WrongEnumState>
    with BlocPresentationMixin<WrongEnumState, WrongEnumPresentationEvent> {
  Test4Cubit() : super(WrongEnumState.one);
}

// expect_lint: bloc_related_class_naming
enum WrongEnumEvent { one }

// expect_lint: bloc_related_class_naming
enum WrongEnumState { one }

// expect_lint: bloc_related_class_naming
enum WrongEnumPresentationEvent { one }

// endregion

///////////////////////////////////////////////////////////////////////

// region Correct blocs

// No lint when names are correct
class CorrectBloc extends Bloc<CorrectEvent, CorrectState>
    with BlocPresentationMixin<CorrectState, CorrectPresentationEvent> {
  CorrectBloc() : super(CorrectState());
}

class CorrectEvent {}

class CorrectState {}

class CorrectPresentationEvent {}

// No lint when class is from the same package, but another file
class SamePackageBloc extends Bloc<ClassFromSamePackage, ClassFromSamePackage>
    with BlocPresentationMixin<ClassFromSamePackage, ClassFromSamePackage> {
  SamePackageBloc() : super(ClassFromSamePackage());
}

// No lint then class is from another package
class AnotherPackageBloc extends Bloc<int, int>
    with BlocPresentationMixin<int, int> {
  AnotherPackageBloc() : super(0);
}

// endregion
