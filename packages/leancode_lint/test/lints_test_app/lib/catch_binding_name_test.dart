Object? someFunction() {
  try {
    // expect_lint: catch_binding_name
  } catch (exception) {
    return exception;
  }

  try {
    // expect_lint: catch_binding_name
  } catch (err, stackTrace) {
    return stackTrace;
  }

  try {} catch (err, st) {
    return st;
  }

  return null;
}
