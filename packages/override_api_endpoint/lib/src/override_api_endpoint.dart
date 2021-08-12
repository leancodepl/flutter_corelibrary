import 'package:shared_preferences/shared_preferences.dart';

typedef GetUri = Future<Uri?> Function();

/// Overrides and persists API endpoint for the test environment
///
/// The `deeplinkOverrideSegment` is the part of deeplink that uniquely
/// identifies deepling that is used to override API endpoint
/// eg. `override` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
///
/// The `deeplinkQueryParameter` is the query parameter of the override API
/// endpoint deeplink that contains url encoded API endpoint to be used
/// eg. `apiAddress` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
///
/// The `defaultEndpoint` is fallback url that should be used if app does not
/// have any endpoint introduced via deeplink or if `deeplinkQueryParameter` is
/// not provided
Future<Uri> overrideApiEndpoint(
  SharedPreferences _sharedPreferences,
  GetUri _getInitialUri,
  String deeplinkOverrideSegment,
  String deeplinkQueryParameter,
  Uri defaultEndpoint, {
  String apiEndpointKey = 'apiAddress',
}) async {
  var apiEndpoint = defaultEndpoint;

  if (_sharedPreferences.containsKey(apiEndpointKey)) {
    apiEndpoint = Uri.parse(_sharedPreferences.getString(apiEndpointKey)!);
  }

  final initial = await _getInitialUri();

  if (initial != null && initial.path.contains(deeplinkOverrideSegment)) {
    final endpointFromDeeplink =
        initial.queryParameters[deeplinkQueryParameter];
    if (endpointFromDeeplink?.isEmpty ?? true) {
      _sharedPreferences.remove(apiEndpointKey);
      apiEndpoint = defaultEndpoint;
    } else {
      apiEndpoint = Uri.parse(endpointFromDeeplink!);
      _sharedPreferences.setString(apiEndpointKey, apiEndpoint.toString());
    }
  }

  return apiEndpoint;
}
