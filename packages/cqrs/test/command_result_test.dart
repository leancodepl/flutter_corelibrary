import 'package:cqrs/src/command_result.dart';
import 'package:test/test.dart';

void main() {
  group('CommandResult', () {
    const error1 = ValidationError(1, 'First error');
    const error2 = ValidationError(2, 'Second error');

    group('fields values are correct', () {
      test('when constructed without errors with success', () {
        const result = CommandResult([], success: true);

        expect(result.success, true);
        expect(result.errors, isEmpty);
      });

      test('when constructed with errors without success', () {
        const result = CommandResult([error1, error2], success: false);

        expect(result.success, false);
        expect(result.errors, hasLength(2));
      });
    });

    group('hasError returns correct values', () {
      test('when there are some errors present', () {
        const result = CommandResult([error1, error2], success: false);

        expect(result.hasError(1), true);
        expect(result.hasError(2), true);
        expect(result.hasError(3), false);
      });

      test('when there are no errors present', () {
        const result = CommandResult([], success: false);

        expect(result.hasError(1), false);
        expect(result.hasError(2), false);
        expect(result.hasError(3), false);
      });
    });

    group('is correctly deserialized from JSON', () {
      test('with some validation errors', () {
        final result = CommandResult.fromJson({
          'WasSuccessful': false,
          'ValidationErrors': [
            {
              'ErrorCode': 12,
              'ErrorMessage': 'This is an error.',
            },
          ],
        });

        expect(
          result,
          isA<CommandResult>()
              .having((r) => r.success, 'success', false)
              .having(
                (r) => r.errors,
                'errors',
                contains(
                  isA<ValidationError>()
                      .having((e) => e.code, 'code', 12)
                      .having((e) => e.message, 'message', 'This is an error.'),
                ),
              ),
        );
      });

      test('without validation errors, with success', () {
        final result = CommandResult.fromJson({
          'WasSuccessful': true,
          'ValidationErrors': [],
        });

        expect(
          result,
          isA<CommandResult>()
              .having((r) => r.success, 'success', true)
              .having((r) => r.errors, 'errors', isEmpty),
        );
      });
    });
  });
}
