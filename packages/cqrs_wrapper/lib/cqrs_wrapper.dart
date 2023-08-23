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

/// A library providing a convenient way of handling CQRS errors.
///
/// Example:
///
/// ```dart
/// final apiUri = Uri.parse('https://budget.manager/api/');
/// final logger = Logger('BudgetManager')
///
/// final cqrs = Cqrs(
///   loginClient,
///   apiUri,
/// );
///
/// final cqrsWrapper = CqrsWrapper(
///   cqrs: cqrs,
///   logger: logger,
/// );
///
/// // Fetching first page of the transactions with error handling
/// final result = await cqrsWrapper.noThrowGet(AllTransactions(page: 1));
///
/// if (result.isSuccesful) {
///   print(result.data);
/// } else if (result.isFailure) {
///   print(result.error);
/// }
///
/// // Adding a new transaction and
/// final result = await cqrsWrapper.noThrowRun(
///   AddTransaction(
///     amount: 100,
///     title: 'Groceries',
///   ),
/// );
///
/// if (result.isSuccess) {
///   print('Transaction added succefully');
/// } else if (result.isInvalid) {
///   print('Invalid data passed');
/// } else if (result.isFailure) {
///   print('Something failed');
/// }
/// ```
library;

export 'src/cqrs_error.dart';
export 'src/cqrs_result.dart';
export 'src/cqrs_wrapper.dart';
