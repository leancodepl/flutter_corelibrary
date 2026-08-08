part of '../mock_libraries.dart';

mixin MockFlutterBloc on AnalysisRuleTest {
  @override
  void setUp() {
    newPackage('flutter_bloc').addFile('lib/flutter_bloc.dart', '''
import 'package:flutter/material.dart';

export 'package:bloc/bloc.dart';

extension BlocContextExtention on BuildContext {
  T read<T>() => throw UnimplementedError();

  T watch<T>() => throw UnimplementedError();
}
''');
    super.setUp();
  }
}
