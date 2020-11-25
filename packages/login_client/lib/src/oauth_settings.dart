import 'package:meta/meta.dart';

class OAuthSettings {
  const OAuthSettings({
    @required this.authorizationEndpointUri,
    this.clientId,
    this.clientSecret,
    this.scopes = const [],
  });

  final Uri authorizationEndpointUri;
  final String clientId;
  final String clientSecret;
  final List<String> scopes;
}
