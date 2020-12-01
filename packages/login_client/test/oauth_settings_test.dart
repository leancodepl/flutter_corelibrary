import 'package:test/test.dart';

import 'package:login_client/src/oauth_settings.dart';

void main() {
  group('OAuthSettings', () {
    final authorizationUri = Uri.parse('https://api.example.com/auth');
    OAuthSettings settings;
    setUp(() {
      settings = OAuthSettings(
        authorizationEndpointUri: authorizationUri,
        clientId: 'com.example.client',
        clientSecret: 's3cr3t',
        scopes: ['email', 'profile'],
      );
    });

    test('has authorizationEndpointUri property set', () {
      expect(settings.authorizationEndpointUri, authorizationUri);
    });

    test('has clientId property set', () {
      expect(settings.clientId, 'com.example.client');
    });

    test('has clientSecret property set', () {
      expect(settings.clientSecret, 's3cr3t');
    });

    test('has scopes property set', () {
      expect(settings.scopes, ['email', 'profile']);
    });
  });
}
