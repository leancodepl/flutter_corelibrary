// for tests
// ignore_for_file: prefer_equatable_mixin

import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc-related classes that are not `equatable` are flagged
class Test1Bloc extends Bloc<Test1Event, Test1State>
    with BlocPresentationMixin<Test1State, Test1PresentationEvent> {
  Test1Bloc() : super(Test1State());
}

final class
// expect_lint: bloc_related_classes_equatable
Test1Event {}

final class
// expect_lint: bloc_related_classes_equatable
Test1State {}

final class
// expect_lint: bloc_related_classes_equatable
Test1PresentationEvent {}

//////////////////////////////////////////////////////////////////////////

// Bloc-related classes that `extend Equatable` are not flagged
class Test2Bloc extends Bloc<Test2Event, Test2State>
    with BlocPresentationMixin<Test2State, Test2PresentationEvent> {
  Test2Bloc() : super(Test2State());
}

final class Test2Event extends Equatable {
  @override
  List<Object?> get props => [];
}

final class Test2State extends Equatable {
  @override
  List<Object?> get props => [];
}

final class Test2PresentationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

//////////////////////////////////////////////////////////////////////////

// Bloc-related classes that `mixin EquatableMixin` are not flagged
class Test3Bloc extends Bloc<Test3Event, Test3State>
    with BlocPresentationMixin<Test3State, Test3PresentationEvent> {
  Test3Bloc() : super(Test3State());
}

final class Test3Event with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class Test3State with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class Test3PresentationEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

//////////////////////////////////////////////////////////////////////////

// Bloc-related enums are not flagged
class Test4Bloc extends Bloc<Test4Event, Test4State>
    with BlocPresentationMixin<Test4State, Test4PresentationEvent> {
  Test4Bloc() : super(Test4State.one);
}

enum Test4Event { event1 }

enum Test4State { one }

enum Test4PresentationEvent { event1 }
