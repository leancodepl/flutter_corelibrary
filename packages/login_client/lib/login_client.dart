// Copyright 2020 LeanCode Sp. z o.o.
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

/// An OAuth2 compliant login client library.
library login_client;

export 'src/credentials_storage/credentials_storage.dart';
export 'src/credentials_storage/in_memory_credentials_storage.dart';
export 'src/login_client.dart';
export 'src/oauth_settings.dart';
export 'src/refresh_exception.dart';
export 'src/strategies/authorization_strategy.dart';
export 'src/strategies/client_credentials_strategy.dart';
export 'src/strategies/custom_grant_strategy.dart';
export 'src/strategies/raw_credentials_strategy.dart';
export 'src/strategies/resource_owner_password_strategy.dart';
export 'src/strategies/sms_token_strategy.dart';
