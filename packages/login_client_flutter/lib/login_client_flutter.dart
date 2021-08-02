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

/// flutter_secure_storage implementation of the credentials storage.
///
/// See also:
/// - https://github.com/mogol/flutter_secure_storage
library login_client_flutter;

export 'src/flutter_secure_credentials_storage_stub.dart'
    if (dart.library.io) 'src/flutter_secure_credentials_storage.dart';

export 'src/mobile_web_credentials_storage_stub.dart'
    if (dart.library.js) 'src/mobile_web_credentials_storage_js.dart'
    if (dart.library.io) 'src/mobile_web_credentials_storage_io.dart';
