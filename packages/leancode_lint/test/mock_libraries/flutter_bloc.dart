part of '../mock_libraries.dart';

mixin MockFlutterBloc on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('flutter_bloc').addFile('lib/flutter_bloc.dart', '''
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

export 'package:bloc/bloc.dart';

extension BlocContextExtention on BuildContext {
  T read<T>() => throw UnimplementedError();

  T watch<T>() => throw UnimplementedError();
}

class BlocProvider<T extends BlocBase<Object?>> extends Widget {
  const BlocProvider({super.key, required this.create, this.child});
  final T Function(BuildContext context) create;
  final Widget? child;
}
''');
    super.setUp();
  }
}
