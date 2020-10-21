import 'package:cqrs/src/command_result.dart';
import 'package:test/test.dart';

void main() {
  group('CommandResult', () {
    const error1 = ValidationError(1, 'First error');
    const error2 = ValidationError(2, 'Second error');

    test('has correct fields values', () {
      const result1 = CommandResult([], success: true);

      expect(result1.success, true);
      expect(result1.errors, isEmpty);

      const result2 = CommandResult([error1, error2], success: false);

      expect(result2.success, false);
      expect(result2.errors, hasLength(2));
    });

    test('hasError returns correct values', () {
      const result1 = CommandResult([error1, error2], success: false);

      expect(result1.hasError(1), true);
      expect(result1.hasError(2), true);
      expect(result1.hasError(3), false);

      const result2 = CommandResult([error2], success: false);

      expect(result2.hasError(1), false);
      expect(result2.hasError(2), true);
      expect(result2.hasError(3), false);

      const result3 = CommandResult([], success: false);

      expect(result3.hasError(1), false);
      expect(result3.hasError(2), false);
      expect(result3.hasError(3), false);
    });

    test('is correctly deserialized from JSON', () {
      final result1 = CommandResult.fromJson({
        'WasSuccessful': false,
        'ValidationErrors': [
          {
            'ErrorCode': 12,
            'ErrorMessage': 'This is an error.',
          },
        ],
      });

      expect(
        result1,
        isA<CommandResult>().having((r) => r.success, 'success', false).having(
              (r) => r.errors,
              'errors',
              contains(
                isA<ValidationError>()
                    .having((e) => e.code, 'code', 12)
                    .having((e) => e.message, 'message', 'This is an error.'),
              ),
            ),
      );

      final result2 = CommandResult.fromJson({
        'WasSuccessful': true,
        'ValidationErrors': [],
      });

      expect(
        result2,
        isA<CommandResult>()
            .having((r) => r.success, 'success', true)
            .having((r) => r.errors, 'errors', isEmpty),
      );
    });
  });
}
