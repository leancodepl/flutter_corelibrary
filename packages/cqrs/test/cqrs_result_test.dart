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
        const result = QueryFailure<bool>(QueryError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, QueryError.unknown);
      });
    });
  });

  group('CommandResult', () {
    group('fields values are correct', () {
      test('when constructed as success', () {
        const result = CommandSuccess();

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.isInvalid, false);
        expect(result.props.isEmpty, true);
      });

      test('when constructed as failure without validation errors', () {
        const result = CommandFailure(CommandError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, false);
        expect(result.validationErrors.isEmpty, true);
        expect(result.error, CommandError.unknown);
      });

      test('when constructed as failure with validation errors', () {
        const result = CommandFailure(
          CommandError.validation,
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
        expect(result.error, CommandError.validation);
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
        const result = OperationFailure<bool>(OperationError.unknown);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.error, OperationError.unknown);
      });
    });
  });
}
