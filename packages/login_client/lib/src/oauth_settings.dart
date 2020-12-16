// Copyright 2021 LeanCode Sp. z o.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// OAuth2 authorization requests settings.
class OAuthSettings {
  /// Creates the [OAuthSettings].
  const OAuthSettings({
    required this.authorizationUri,
    required this.clientId,
    this.clientSecret = '',
    this.scopes = const [],
  })  : assert(clientId != null),
        assert(clientSecret != null);

  /// The [`authorization endpoint`](https://tools.ietf.org/html/rfc6749#section-3.1)
  /// from the RFC 6749.
  final Uri authorizationUri;

  /// The [`client_id`](https://tools.ietf.org/html/rfc6749#appendix-A.1)
  /// from the RFC 6749.
  final String? clientId;

  /// The [`client_secret`](https://tools.ietf.org/html/rfc6749#appendix-A.2)
  /// from the RFC 6749.
  final String? clientSecret;

  /// The [`scope`](https://tools.ietf.org/html/rfc6749#appendix-A.4)
  /// from the RFC 6749.
  final List<String> scopes;
}
