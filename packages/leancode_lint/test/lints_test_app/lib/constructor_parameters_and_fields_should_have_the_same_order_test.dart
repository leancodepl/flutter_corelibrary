class ClassWithInvalidUnnamedParametersOrder {
  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
  const ClassWithInvalidUnnamedParametersOrder(
    this.third,
    this.second,
    this.first,
    this.fourth,
    this.fifth,
  );

  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
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

class ClassWithInvalidNamedParametersOrder {
  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
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

class ClassWithInvalidNamedParametersOrderAndWithNonThisParameter {
  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
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

  // ignore: unused_field
  final String _otherParameter;
}

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

  // ignore: unused_field
  final String _otherParameter;
}

class ClassWithInvalidUnnamedParametersOrderAndWithNonThisParameter {
  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
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

  // ignore: unused_field
  final String _otherParameter;
}

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

  // ignore: unused_field
  final String _otherParameter;
}

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

  // ignore: unused_field
  final String _test;
}

class ClassWithMixedParametersWithInvalidOrder extends _AbstractClassWithField {
  // expect_lint: constructor_parameters_and_fields_should_have_the_same_order
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

  // ignore: unused_field
  final String _test;
}

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
