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

/// A library for convenient communication with CQRS-compatible backends, using
/// queries and commands.
///
/// Example:
///
/// ```dart
/// final apiUri = Uri.parse('https://flowers.garden/api/');
///
/// final cqrs = CQRS(
///   loginClient,
///   apiUri,
/// );
///
/// // Fetching first page of flowers
/// final flowers = await cqrs.get(AllFlowers()..page = 1);
///
/// // Adding a new flower
/// final result = await cqrs.run(AddFlower()
///   ..name = 'Daisy'
///   ..pretty = true);
///
/// print(result.success); // true
/// ```
///
/// See also:
///
/// - https://github.com/leancodepl/corelibrary
/// - https://www.nuget.org/packages/LeanCode.ContractsGenerator/ - code
/// generation tool for easy contracts transpilation from C# to Dart and
/// TypeScript.
library cqrs;

export 'src/command_result.dart';
export 'src/cqrs.dart';
export 'src/cqrs_exception.dart';
export 'src/transport_types.dart';
