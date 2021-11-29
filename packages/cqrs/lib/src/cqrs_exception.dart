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

import 'package:cqrs/cqrs.dart';
import 'package:http/http.dart';

/// Usually thrown by [CQRS.get] or [CQRS.run].
class CQRSException implements Exception {
  /// Creates a [CQRSException] with [response] and [message].
  const CQRSException(this.response, [this.message]);

  /// Server's response to the request that triggered this exception.
  final Response response;

  /// Server's message.
  final String? message;

  @override
  String toString() {
    final builder = StringBuffer();

    if (message != null) {
      builder.writeln(message);
    }

    builder
      ..writeln(
        'Server returned a ${response.statusCode} ${response.reasonPhrase} '
        'status. Response body:',
      )
      ..write(response.body);

    return builder.toString();
  }
}
