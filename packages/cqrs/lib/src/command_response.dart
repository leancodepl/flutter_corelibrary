// Copyright 2023 LeanCode Sp. z o.o.
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

import 'transport_types.dart';
import 'validation_error.dart';

/// The result of running a [Command].
class CommandResponse {
  /// Creates a [CommandResponse] with [errors];
  const CommandResponse(this.errors);

  /// Creates a success [CommandResponse] without any errors.
  const CommandResponse.success() : errors = const [];

  /// Creates a failed [CommandResponse] and ensures it has errors.
  CommandResponse.failed(this.errors) : assert(errors.isNotEmpty);

  /// Creates a [CommandResponse] from JSON.
  CommandResponse.fromJson(Map<String, dynamic> json)
      : errors = (json['ValidationErrors'] as List)
            .map(
              (dynamic error) =>
                  ValidationError.fromJson(error as Map<String, dynamic>),
            )
            .toList();

  /// Whether the command has succeeded.
  bool get success => errors.isEmpty;

  /// Whether the command has failed with [errors].
  bool get failed => errors.isNotEmpty;

  /// Validation errors related to the data carried by the [Command].
  final List<ValidationError> errors;

  /// Serializes this [CommandResponse] to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'WasSuccessful': success,
        'ValidationErrors': errors.map((error) => error.toJson()).toList(),
      };

  @override
  String toString() => 'CommandResult($errors)';
}
