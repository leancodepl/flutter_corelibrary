import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:leancode_lint/lints/constructor_parameters_and_fields_should_have_the_same_order.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(
      ConstructorParametersAndFieldsShouldHaveTheSameOrderTest,
    );
  });
}

@reflectiveTest
class ConstructorParametersAndFieldsShouldHaveTheSameOrderTest
    extends AnalysisRuleTest {
  final rule = ConstructorParametersAndFieldsShouldHaveTheSameOrder();

  @override
  void setUp() {
    Registry.ruleRegistry.registerWarningRule(rule);
    super.setUp();
  }

  @override
  String get analysisRule => rule.name;

  Future<void> test_invalid_unnamed_parameters_order() async {
    await assertDiagnostics(
      '''
class ClassWithInvalidUnnamedParametersOrder {
  const ClassWithInvalidUnnamedParametersOrder(
    this.third,
    this.second,
    this.first,
    this.fourth,
    this.fifth,
  );

  const ClassWithInvalidUnnamedParametersOrder.anotherConstructor(
    this.third,
    this.second,
    this.first,
    this.fourth,
    this.fifth,
  );

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}
''',
      [lint(49, 132), lint(185, 151)],
    );
  }

  Future<void> test_invalid_named_parameters_order() async {
    await assertDiagnostics(
      '''
class ClassWithInvalidNamedParametersOrder {
  const ClassWithInvalidNamedParametersOrder({
    required this.third,
    required this.first,
    required this.fourth,
    required this.fifth,
    required this.second,
  });

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}
''',
      [lint(47, 177)],
    );
  }

  Future<void> test_valid_unnamed_parameters_order() async {
    await assertNoDiagnostics('''
class ClassWithValidUnnamedParametersOrder {
  const ClassWithValidUnnamedParametersOrder(
    this.first,
    this.second,
    this.third,
    this.fourth,
    this.fifth,
  );

  const ClassWithValidUnnamedParametersOrder.anotherConstructor(
    this.first,
    this.second,
    this.third,
    this.fourth,
    this.fifth,
  );

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}
''');
  }

  Future<void> test_valid_named_parameters_order() async {
    await assertNoDiagnostics('''
class ClassWithValidNamedParametersOrder {
  const ClassWithValidNamedParametersOrder({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
  });

  const ClassWithValidNamedParametersOrder.anotherConstructor({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
  });

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}
''');
  }

  Future<void>
  test_invalid_named_parameters_order_and_with_non_this_parameter() async {
    await assertDiagnostics(
      '''
class ClassWithInvalidNamedParametersOrderAndWithNonThisParameter {
  const ClassWithInvalidNamedParametersOrderAndWithNonThisParameter({
    required this.first,
    required this.second,
    required String otherParameter,
    required this.third,
    required this.fourth,
    required this.fifth,
  }) : _otherParameter = otherParameter;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _otherParameter;
}
''',
      [lint(70, 271)],
    );
  }

  Future<void>
  test_valid_named_parameters_order_and_with_non_this_parameter() async {
    await assertNoDiagnostics('''
class ClassWithValidNamedParametersOrderAndWithNonThisParameter {
  const ClassWithValidNamedParametersOrderAndWithNonThisParameter({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required String otherParameter,
  }) : _otherParameter = otherParameter;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _otherParameter;
}
''');
  }

  Future<void>
  test_invalid_unnamed_parameters_order_and_with_non_this_parameter() async {
    await assertDiagnostics(
      '''
class ClassWithInvalidUnnamedParametersOrderAndWithNonThisParameter {
  const ClassWithInvalidUnnamedParametersOrderAndWithNonThisParameter(
    this.third,
    this.second,
    String otherParameter,
    this.first,
    this.fourth,
    this.fifth,
  ) : _otherParameter = otherParameter;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _otherParameter;
}
''',
      [lint(72, 217)],
    );
  }

  Future<void>
  test_valid_unnamed_parameters_order_and_with_non_this_parameter() async {
    await assertNoDiagnostics('''
class ClassWithValidUnnamedParametersOrderAndWithNonThisParameter {
  const ClassWithValidUnnamedParametersOrderAndWithNonThisParameter(
    this.first,
    this.second,
    this.third,
    this.fourth,
    this.fifth,
    String otherParameter,
  ) : _otherParameter = otherParameter;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _otherParameter;
}
''');
  }

  Future<void>
  test_valid_unnamed_parameters_order_and_with_super_parameter() async {
    await assertNoDiagnostics('''
class ClassWithValidUnnamedParametersOrderAndWithSuperParameter
    extends _AbstractClassWithField {
  const ClassWithValidUnnamedParametersOrderAndWithSuperParameter(
    this.first,
    this.second,
    this.third,
    this.fourth,
    this.fifth,
    super.a,
  );

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}

abstract class _AbstractClassWithField {
  const _AbstractClassWithField(this.a);

  final int a;
}
''');
  }

  Future<void> test_mixed_parameters_with_valid_order() async {
    await assertNoDiagnostics('''
class ClassWithMixedParametersWithValidOrder extends _AbstractClassWithField {
  const ClassWithMixedParametersWithValidOrder(
    super.a,
    this.first,
    this.second, {
    required this.third,
    required this.fourth,
    required this.fifth,
    required String test,
  }) : _test = test;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _test;
}

abstract class _AbstractClassWithField {
  const _AbstractClassWithField(this.a);

  final int a;
}
''');
  }

  Future<void> test_mixed_parameters_with_invalid_order() async {
    await assertDiagnostics(
      '''
class ClassWithMixedParametersWithInvalidOrder extends _AbstractClassWithField {
  const ClassWithMixedParametersWithInvalidOrder(
    super.a,
    this.second,
    this.first, {
    required this.third,
    required this.fourth,
    required String test,
    required this.fifth,
  }) : _test = test;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;

  final String _test;
}

abstract class _AbstractClassWithField {
  const _AbstractClassWithField(this.a);

  final int a;
}
''',
      [lint(83, 218)],
    );
  }

  Future<void> test_valid_order_but_one_field_set_in_constructor_body() async {
    await assertNoDiagnostics('''
class ClassWithValidOrderButOneFieldSetInConstructorBody {
  const ClassWithValidOrderButOneFieldSetInConstructorBody({
    required this.first,
    required this.second,
    required this.fourth,
    required this.fifth,
  }) : third = 3;

  final int first;
  final int second;
  final int third;
  final int fourth;
  final int fifth;
}
''');
  }

  Future<void> test_valid_order_but_one_field_has_initializer() async {
    await assertNoDiagnostics('''
class ClassWithValidOrderButOneFieldHasInitializer {
  const ClassWithValidOrderButOneFieldHasInitializer({
    required this.first,
    required this.second,
    required this.fourth,
    required this.fifth,
  });

  final int first;
  final int second;
  final third = 3;
  final int fourth;
  final int fifth;
}
''');
  }

  Future<void> test_valid_order_but_one_field_is_nullable_and_mutable() async {
    await assertNoDiagnostics('''
class ClassWithValidOrderButOneFieldIsNullableAndMutable {
  ClassWithValidOrderButOneFieldIsNullableAndMutable({
    required this.first,
    required this.second,
    required this.fourth,
    required this.fifth,
  });

  final int first;
  final int second;
  int? third;
  final int fourth;
  final int fifth;
}
''');
  }
}
