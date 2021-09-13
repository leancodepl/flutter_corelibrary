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

import 'transport_types.dart';

/// The result of running a [Command].
class CommandResult {
  const CommandResult(this.errors);

  /// Creates a success [CommandResult] without any errors.
  const CommandResult.success() : errors = const [];

  /// Creates a failed [CommandResult] and ensures it has errors.
  CommandResult.failed(this.errors) : assert(errors.isNotEmpty);

  CommandResult.fromJson(Map<String, dynamic> json)
      : errors = (json['ValidationErrors'] as List)
            .map((error) =>
                ValidationError.fromJson(error as Map<String, dynamic>))
            .toList();

  /// Whether the command has succeeded.
  bool get success => errors.isEmpty;

  /// Whether the command has failed with [errors].
  bool get failed => errors.isNotEmpty;

  /// Validation errors related to the data carried by the [Command].
  final List<ValidationError> errors;

  /// Checks whether this [CommandResult] contains a provided error `code` in
  /// its validation errors.
  bool hasError(int code) => errors.any((error) => error.code == code);

  /// Checks whether this [CommandResult] contains a provided error `code` in
  /// its validation errors related to the `propertyName`.
  bool hasErrorForProperty(int code, String propertyName) => errors
      .any((error) => error.code == code && error.propertyName == propertyName);

  Map<String, dynamic> toJson() => {
        'WasSuccessful': success,
        'ValidationErrors': errors.map((error) => error.toJson()).toList(),
      };
}

/// A validation error.
class ValidationError {
  const ValidationError(this.code, this.message, this.propertyName);

  ValidationError.fromJson(Map<String, dynamic> json)
      : code = json['ErrorCode'] as int,
        message = json['ErrorMessage'] as String,
        propertyName = json['PropertyName'] as String;

  /// Code of the validation error.
  final int code;

  /// Message describing the validation error.
  final String message;

  /// Path to the property which caused the error.
  final String propertyName;

  Map<String, dynamic> toJson() => {
        'ErrorCode': code,
        'ErrorMessage': message,
        'PropertyName': propertyName
      };

  @override
  String toString() => '[$propertyName] $code: $message';
}
