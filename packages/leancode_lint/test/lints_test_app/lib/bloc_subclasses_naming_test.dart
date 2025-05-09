import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Invalid name of a state subclass is flagged
class Test1Cubit extends Cubit<Test1State> {
  Test1Cubit() : super(InvalidState());
}

sealed class Test1State {}

final class
// expect_lint: bloc_subclasses_naming
InvalidState
    extends Test1State {}

//////////////////////////////////////////////////////////////////////////

// Invalid name of an event subclass is flagged
class Test2Bloc extends Bloc<Test2Event, Test2State> {
  Test2Bloc() : super(Test2State());
}

final class Test2State {}

sealed class Test2Event {}

final class
// expect_lint: bloc_subclasses_naming
InvalidEvent
    extends Test2Event {}

//////////////////////////////////////////////////////////////////////////

// Invalid name of a presentation event subclass is flagged
class Test3Cubit extends Cubit<Test3State>
    with BlocPresentationMixin<Test3State, Test3Event> {
  Test3Cubit() : super(Test3State());
}

final class Test3State {}

sealed class Test3Event {}

final class
// expect_lint: bloc_subclasses_naming
InvalidPresentationEvent
    extends Test3Event {}

//////////////////////////////////////////////////////////////////////////

// Valid subclass names for a cubit are not flagged

class Test4Cubit extends Cubit<Test4State>
    with BlocPresentationMixin<Test4State, Test4Event> {
  Test4Cubit() : super(Test4StateFoo());
}

sealed class Test4State {}

final class Test4StateFoo extends Test4State {}

final class Test4StateBar extends Test4State {}

sealed class Test4Event {}

final class Test4EventFoo extends Test4Event {}

final class Test4EventBar extends Test4Event {}

//////////////////////////////////////////////////////////////////////////

// Valid subclass names for a bloc are not flagged
class Test5Bloc extends Bloc<Test5Event, Test5State>
    with BlocPresentationMixin<Test5State, Test5PresentationEvent> {
  Test5Bloc() : super(Test5StateFoo());
}

sealed class Test5State {}

final class Test5StateFoo extends Test5State {}

final class Test5StateBar extends Test5State {}

sealed class Test5Event {}

final class Test5EventFoo extends Test5Event {}

final class Test5EventBar extends Test5Event {}

sealed class Test5PresentationEvent {}

final class Test5PresentationEventFoo extends Test5PresentationEvent {}

final class Test5PresentationEventBar extends Test5PresentationEvent {}
