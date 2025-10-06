import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Overrides and persists API endpoint for the test environment
///
/// The `deeplinkOverrideSegment` is the part of deeplink that uniquely
/// identifies deeplink that is used to override API endpoint
/// eg. `override` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
///
/// The `deeplinkQueryParameter` is the query parameter of the override API
/// endpoint deeplink that contains url encoded API endpoint to be used
/// eg. `apiAddress` in `app://app/override?apiAddress=https%3A%2F%2Fexample.com`
///
/// To clear the persisted endpoint and return to the default one, use 'clear'
/// as the query parameter value
/// eg. `app://app/override?apiAddress=clear`
///
/// The `defaultEndpoint` is fallback url that should be used if app does not
/// have any endpoint introduced via deeplink or if `deeplinkQueryParameter` is
/// not provided
Future<Uri> overrideApiEndpoint({
  required SharedPreferences sharedPreferences,
  required FutureOr<Uri?> Function() getInitialUri,
  required String deeplinkOverrideSegment,
  required String deeplinkQueryParameter,
  required Uri defaultEndpoint,
  String apiEndpointKey = 'apiAddress',
}) async {
  var apiEndpoint = defaultEndpoint;

  if (sharedPreferences.containsKey(apiEndpointKey)) {
    apiEndpoint = Uri.parse(sharedPreferences.getString(apiEndpointKey)!);
  }

  final initial = await getInitialUri();

  if (initial != null && initial.path.contains(deeplinkOverrideSegment)) {
    final endpointFromDeeplink =
        initial.queryParameters[deeplinkQueryParameter];
    if (endpointFromDeeplink == 'clear') {
      await sharedPreferences.remove(apiEndpointKey);
      apiEndpoint = defaultEndpoint;
    } else if (endpointFromDeeplink?.isNotEmpty ?? false) {
      apiEndpoint = Uri.parse(endpointFromDeeplink!);
      await sharedPreferences.setString(apiEndpointKey, apiEndpoint.toString());
    }
  }

  return apiEndpoint;
}
