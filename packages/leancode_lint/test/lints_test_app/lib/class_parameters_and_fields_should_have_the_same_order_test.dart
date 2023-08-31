class ClassWithInvalidUnnamedParametersOrder {
  const ClassWithInvalidUnnamedParametersOrder(
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
    this.third,
    this.second,
    this.first,
    this.fourth,
    this.fifth,
  );

  const ClassWithInvalidUnnamedParametersOrder.anotherConstructor(
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
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
  const ClassWithInvalidNamedParametersOrder({
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
    required this.third,
    required this.first,
    required this.fourth,
    required this.fifth,
    required this.second,
  });

  const ClassWithInvalidNamedParametersOrder.anotherConstructor({
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
    required this.third,
    required this.second,
    required this.first,
    required this.fourth,
    required this.fifth,
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

class ClassWithInvalidNamedParametersOrderWithNonThis {
  const ClassWithInvalidNamedParametersOrderWithNonThis({
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
    required this.first,
    required this.second,
    required String otherParameter,
    required this.third,
    required this.fourth,
    required this.fifth,
  }) : _otherParameter = otherParameter;

  const ClassWithInvalidNamedParametersOrderWithNonThis.anotherConstructor({
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
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

class ClassWithValidNamedParametersOrderWithNonThis {
  const ClassWithValidNamedParametersOrderWithNonThis({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required String otherParameter,
  }) : _otherParameter = otherParameter;

  const ClassWithValidNamedParametersOrderWithNonThis.anotherConstructor({
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

class ClassWithInvalidUnnamedParametersOrderWithNonThis {
  const ClassWithInvalidUnnamedParametersOrderWithNonThis(
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
    this.third,
    this.second,
    String otherParameter,
    this.first,
    this.fourth,
    this.fifth,
  ) : _otherParameter = otherParameter;

  const ClassWithInvalidUnnamedParametersOrderWithNonThis.anotherConstructor(
    // expect_lint: class_parameters_and_fields_should_have_the_same_order
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

class ClassWithValidUnnamedParametersOrderWithNonThis {
  const ClassWithValidUnnamedParametersOrderWithNonThis(
    this.first,
    this.second,
    this.third,
    this.fourth,
    this.fifth,
    String otherParameter,
  ) : _otherParameter = otherParameter;

  const ClassWithValidUnnamedParametersOrderWithNonThis.anotherConstructor(
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
