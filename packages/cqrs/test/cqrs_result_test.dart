import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  group('QueryResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = QuerySuccess(true);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
      });

      test('when constructed as failure', () {
        const result = QueryFailure<bool>(QueryErrorType.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, CqrsError.unknown);
      });
    });
  });

  group('CommandResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CommandSuccess(null);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.isInvalid, false);
        expect(result.props.isEmpty, true);
      });

      test('when constructed as failure without validation errors', () {
        const result = CommandFailure(CommandErrorType.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, false);
        expect(result.validationErrors.isEmpty, true);
        expect(result.error, CqrsError.unknown);
      });

      test('when constructed as failure with validation errors', () {
        const result = CommandFailure(
          CommandErrorType.validation,
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
        expect(result.error, CommandErrorType.validation);
      });
    });
  });

  group('OperationResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = OperationSuccess(true);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, true);
      });

      test('when constructed as failure', () {
        const result = OperationFailure<bool>(OperationErrorType.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, CqrsError.unknown);
      });
    });
  });
}
