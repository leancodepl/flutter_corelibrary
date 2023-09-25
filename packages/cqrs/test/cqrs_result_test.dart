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

  group('CResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CSuccess();

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.isInvalid, false);
        expect(result.props.isEmpty, true);
      });

      test('when constructed as failure without validation errors', () {
        const result = CFailure(CqrsError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, false);
        expect(result.validationErrors.isEmpty, true);
        expect(result.error, CqrsError.unknown);
      });

      test('when constructed as failure with validation errors', () {
        const result = CFailure(
          CqrsError.validation,
          validationErrors: [
            ValidationError(123, 'Test message', 'SomeProperty'),
            ValidationError(456, 'Another message', 'OtherProperty'),
          ],
        );

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, true);
        expect(result.validationErrors, const <ValidationError>[
          ValidationError(123, 'Test message', 'SomeProperty'),
          ValidationError(456, 'Another message', 'OtherProperty'),
        ]);
        expect(result.error, CqrsError.validation);
      });
    });
  });

  group('OResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = OSuccess(true);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
      });

      test('when constructed as failure', () {
        const result = OFailure<bool>(CqrsError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, CqrsError.unknown);
      });
    });
  });
}
