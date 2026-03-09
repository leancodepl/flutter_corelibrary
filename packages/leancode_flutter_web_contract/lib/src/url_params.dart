/// The query parameter key used to pass the contract version.
const String contractVersionQueryKey = 'contractVersion';

/// Base class for accessing URL query parameters from [Uri.base].
class UrlParamsBase {
  /// The contract version extracted from the URL query parameters, if present.
  String? get contractVersion => params[contractVersionQueryKey];

  /// All query parameters from the current URL.
  Map<String, String> get params => Uri.base.queryParameters;
}
