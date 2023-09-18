import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('CqrsQueryResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CqrsQuerySuccess<bool, CqrsError>(true);

        expect(result.asSuccess, result);
        expect(result.asFailure, null);
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
        expect(result.error, null);
      });

      test('when constructed as failure', () {
        const result = CqrsQueryFailure<bool, CqrsError>(CqrsError.unknown);

        expect(result.asSuccess, null);
        expect(result.asFailure, result);
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.data, null);
        expect(result.error, CqrsError.unknown);
      });
    });
  });

  group('CqrsOperationResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CqrsOperationSuccess<bool, CqrsError>(true);

        expect(result.asSuccess, result);
        expect(result.asFailure, null);
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
        expect(result.error, null);
      });

      test('when constructed as failure', () {
        const result = CqrsOperationFailure<bool, CqrsError>(CqrsError.unknown);

        expect(result.asSuccess, null);
        expect(result.asFailure, result);
        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.data, null);
        expect(result.error, CqrsError.unknown);
      });
    });
  });
}
