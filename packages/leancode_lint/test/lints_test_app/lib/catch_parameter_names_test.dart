Object? someFunction() {
  try {
    // expect_lint: catch_parameter_names
  } catch (exception) {
    return exception;
  }

  try {} catch (err,
  // expect_lint: catch_parameter_names
  stackTrace) {
    return stackTrace;
  }

  try {} catch (err, st) {
    return st;
  }

  return null;
}
