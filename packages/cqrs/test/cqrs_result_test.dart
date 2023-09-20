import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('QResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = QSuccess(true);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
      });

      test('when constructed as failure', () {
        const result = QFailure<bool>(CqrsError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, CqrsError.unknown);
      });
    });
  });

  group('CqrsCommandResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CqrsCommandSuccess();

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.isInvalid, false);
        expect(result.validationErrors, const <ValidationError>[]);
      });

      test('when constructed as failure without validation errors', () {
        const result = CqrsCommandFailure(CqrsError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, false);
        expect(result.validationErrors, const <ValidationError>[]);
        expect(result.error, CqrsError.unknown);
      });

      test('when constructed as failure with validation errors', () {
        const result = CqrsCommandFailure(
          CqrsError.validation,
          validationErrors: [
            ValidationError(123, 'Test message', 'SomeProperty'),
            ValidationError(456, 'Another message', 'OtherProperty')
          ],
        );

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, true);
        expect(result.validationErrors, const <ValidationError>[
          ValidationError(123, 'Test message', 'SomeProperty'),
          ValidationError(456, 'Another message', 'OtherProperty')
        ]);
        expect(result.error, CqrsError.validation);
      });
    });
  });

  group('CqrsOperationResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CqrsOperationSuccess(true);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
      });

      test('when constructed as failure', () {
        const result = CqrsOperationFailure<bool>(CqrsError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, CqrsError.unknown);
      });
    });
  });
}
