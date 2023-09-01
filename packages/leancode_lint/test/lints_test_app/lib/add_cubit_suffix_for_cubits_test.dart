import 'package:flutter_bloc/flutter_bloc.dart';

class ProperlyNamedCubit extends Cubit<bool> {
  ProperlyNamedCubit() : super(true);
}

// expect_lint: add_cubit_suffix_for_your_cubits
class NotProperlyNamed extends Cubit<bool> {
  NotProperlyNamed() : super(true);
}

// expect_lint: add_cubit_suffix_for_your_cubits
class NotProperlyNamedWithDifferentSuperClass extends ProperlyNamedCubit {
  NotProperlyNamedWithDifferentSuperClass();
}

class ProperlyNamedWithDifferentSuperClassCubit extends ProperlyNamedCubit {
  ProperlyNamedWithDifferentSuperClassCubit();
}

// expect_lint: add_cubit_suffix_for_your_cubits
class ClassExtendingOtherCubitClassWithoutSuffix extends NotProperlyNamed {
  ClassExtendingOtherCubitClassWithoutSuffix();
}
