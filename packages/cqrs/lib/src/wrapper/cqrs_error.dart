// ignore_for_file: public_member_api_docs

enum CqrsQueryError {
  unknown,
  network,
  forbiddenAccess,
  authentication,
}

enum CqrsCommandError {
  unknown,
  network,
  forbiddenAccess,
  authentication,
  validation,
}
