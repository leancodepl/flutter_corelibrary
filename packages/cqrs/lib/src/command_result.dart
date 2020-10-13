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

/// The result of running a [Command].
class CommandResult {
  const CommandResult(this.errors, {required this.success});

  CommandResult.fromJson(Map<String, dynamic> json)
      : success = json['WasSuccessful'] as bool,
        errors = (json['ValidationErrors'] as List<Map<String, dynamic>>)
            .map((error) => ValidationError.fromJson(error))
            .toList();

  /// Whether the command has succeeded.
  final bool success;

  /// Validation errors related to the data carried by the [Command].
  final List<ValidationError> errors;

  /// Checks whether this [CommandResult] contains a provided error `code` in
  /// its validation errors.
  bool hasError(int code) => errors.any((error) => error.code == code);
}

/// A validation error.
class ValidationError {
  const ValidationError(this.code, this.message);

  ValidationError.fromJson(Map<String, dynamic> json)
      : code = json['ErrorCode'] as int,
        message = json['ErrorMessage'] as String;

  /// Code of the validation error.
  final int code;

  /// Message describing the validation error.
  final String message;

  @override
  String toString() => '$code: $message';
}
