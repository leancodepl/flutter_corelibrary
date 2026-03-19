/// The query parameter key used to pass the contract version.
const String contractVersionQueryKey = 'contractVersion';

/// Base class for accessing URL query parameters from [Uri.base].
abstract class UrlParamsBase {
  /// The contract version extracted from the URL query parameters, if present.
  static String? get contractVersion => params[contractVersionQueryKey];

  /// All query parameters from the current URL.
  static Map<String, String> get params => Uri.base.queryParameters;
}
