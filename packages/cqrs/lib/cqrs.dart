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

/// A library for convenient communication with CQRS-compatible backends, using
/// queries and commands.
///
/// Example:
///
/// ```dart
/// final apiUri = Uri.parse('https://flowers.garden/api/');
///
/// final cqrs = Cqrs(
///   loginClient,
///   apiUri,
/// );
///
/// // Fetching first page of flowers
/// final result = await cqrs.get(AllFlowers(page: 1));
///
/// // Handling query result
/// if (result.isSuccesful) {
///   print(result.data);
/// } else if (result.isFailure) {
///   print('Something failed with error ${result.error}');
/// }
///
/// // Adding a new flower
/// final result = await cqrs.run(
///   AddFlower(
///     name: 'Daisy',
///     pretty: true,
///   ),
/// );
///
/// // Handling command result
/// if (result.isSuccess) {
///   print('Flower added succefully');
/// } else if (result.isInvalid) {
///   print('Validation error occured');
/// } else if (result.isFailure) {
///   print('Something failed with error ${result.error}');
/// }
/// ```
///
/// See also:
///
/// - https://github.com/leancodepl/corelibrary
/// - https://github.com/leancodepl/contractsgenerator - code
/// generation tool for easy contracts transpilation from C# to Dart and
/// TypeScript.
/// - https://github.com/leancodepl/contractsgenerator-dart - dart
/// code contract generator.
library;

export 'src/command_result.dart';
export 'src/cqrs.dart';
export 'src/cqrs_error.dart';
export 'src/cqrs_exception.dart';
export 'src/cqrs_result.dart';
export 'src/transport_types.dart';
