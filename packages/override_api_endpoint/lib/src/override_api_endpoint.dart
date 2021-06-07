import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

Future<Uri> overrideApiEndpoint(
  String deeplinkOverrideSegment,
  String deeplinkQueryParameter,
  Uri defaultEndpoint,
) async {
  const apiEndpointKey = 'apiAddress';

  final sharedPreferences = await SharedPreferences.getInstance();

  var apiEndpoint = defaultEndpoint;

  if (sharedPreferences.containsKey(apiEndpointKey)) {
    apiEndpoint = Uri.parse(sharedPreferences.getString(apiEndpointKey)!);
  }

  final initial = await getInitialUri();

  if (initial != null && initial.path.contains(deeplinkOverrideSegment)) {
    final endpointFromDeeplink =
        initial.queryParameters[deeplinkQueryParameter];
    if (endpointFromDeeplink?.isEmpty ?? true) {
      sharedPreferences.remove(apiEndpointKey);
      apiEndpoint = defaultEndpoint;
    } else {
      apiEndpoint = Uri.parse(endpointFromDeeplink!);
      sharedPreferences.setString(apiEndpointKey, apiEndpoint.toString());
    }
  }

  return apiEndpoint;
}
