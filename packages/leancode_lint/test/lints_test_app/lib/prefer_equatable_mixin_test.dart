import 'package:equatable/equatable.dart';

// Directly extending Equatable is flagged
class MyState
    extends
        // expect_lint: prefer_equatable_mixin
        Equatable {
  @override
  List<Object?> get props => [];
}

//////////////////////////////////////////////////////////////////////////

// Transitively extending Equatable is not flagged
class MyState2 extends MyState {
  @override
  List<Object?> get props => [];
}

//////////////////////////////////////////////////////////////////////////

// Using EquatableMixin is not flagged
class MyState3 with EquatableMixin {
  @override
  List<Object?> get props => [];
}
