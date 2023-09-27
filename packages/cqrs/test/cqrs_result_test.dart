import 'package:cqrs/cqrs.dart';
import 'package:test/test.dart';

void main() {
  const error1 = ValidationError(1, 'First error', 'Property1');
  const error2 = ValidationError(2, 'Second error', 'Property2');

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
          validationErrors: [error1, error2],
        );

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.isInvalid, true);
        expect(result.validationErrors, const [error1, error2]);
        expect(result.error, CommandError.validation);
      });

      group('hasError returns correct values', () {
        test('when there are some errors present', () {
          const result = CommandFailure(
            CommandError.validation,
            validationErrors: [error1, error2],
          );

          expect(result.hasError(1), true);
          expect(result.hasError(2), true);
          expect(result.hasError(3), false);
        });

        test('when there are no errors present', () {
          const result = CommandFailure(CommandError.unknown);

          expect(result.hasError(1), false);
          expect(result.hasError(2), false);
          expect(result.hasError(3), false);
        });
      });

      group('hasErrorForProperty returns correct values', () {
        test('when there are some errors present', () {
          const result = CommandFailure(
            CommandError.validation,
            validationErrors: [error1, error2],
          );

          expect(result.hasErrorForProperty(1, 'Property1'), true);
          expect(result.hasErrorForProperty(2, 'Property2'), true);
        });

        test('when there are errors but for different properties', () {
          const result = CommandFailure(
            CommandError.validation,
            validationErrors: [error1, error2],
          );

          expect(result.hasErrorForProperty(1, 'Property2'), false);
          expect(result.hasErrorForProperty(2, 'Property1'), false);
        });

        test('when there are no errors present', () {
          const result = CommandFailure(CommandError.unknown);

          expect(result.hasErrorForProperty(1, 'Property1'), false);
          expect(result.hasErrorForProperty(2, 'Property1'), false);
          expect(result.hasErrorForProperty(2, 'Property1'), false);
          expect(result.hasErrorForProperty(2, 'Property2'), false);
        });
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
