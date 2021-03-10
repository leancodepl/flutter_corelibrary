import 'package:cqrs/src/command_result.dart';
import 'package:test/test.dart';

void main() {
  group('CommandResult', () {
    const error1 = ValidationError(1, 'First error', 'Property1');
    const error2 = ValidationError(2, 'Second error', 'Property2');

    group('fields values are correct', () {
      test('when constructed without errors', () {
        const result = CommandResult([]);

        expect(result.success, true);
        expect(result.failed, false);
        expect(result.errors, isEmpty);
      });

      test('when constructed with errors', () {
        const result = CommandResult([error1, error2]);

        expect(result.success, false);
        expect(result.failed, true);
        expect(result.errors, hasLength(2));
      });

      test('when constructed with success constructor', () {
        const result = CommandResult.success();

        expect(result.success, true);
        expect(result.failed, false);
        expect(result.errors, isEmpty);
      });

      test('when constructed with success constructor', () {
        final result = CommandResult.failed([error1]);

        expect(result.success, false);
        expect(result.failed, true);
        expect(result.errors, hasLength(1));
      });
    });

    group('hasError returns correct values', () {
      test('when there are some errors present', () {
        const result = CommandResult([error1, error2]);

        expect(result.hasError(1), true);
        expect(result.hasError(2), true);
        expect(result.hasError(3), false);
      });

      test('when there are no errors present', () {
        const result = CommandResult([]);

        expect(result.hasError(1), false);
        expect(result.hasError(2), false);
        expect(result.hasError(3), false);
      });
    });

    group('hasErrorForProperty returns correct values', () {
      test('when there are some errors present', () {
        const result = CommandResult([error1, error2]);

        expect(result.hasErrorForProperty(1, 'Property1'), true);
        expect(result.hasErrorForProperty(2, 'Property2'), true);
      });

      test('when there are errors but for different properties', () {
        const result = CommandResult([error1, error2]);

        expect(result.hasErrorForProperty(1, 'Property2'), false);
        expect(result.hasErrorForProperty(2, 'Property1'), false);
      });

      test('when there are no errors present', () {
        const result = CommandResult([]);

        expect(result.hasErrorForProperty(1, 'Property1'), false);
        expect(result.hasErrorForProperty(2, 'Property1'), false);
        expect(result.hasErrorForProperty(2, 'Property1'), false);
        expect(result.hasErrorForProperty(2, 'Property2'), false);
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
              'PropertyName': 'Property',
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
                contains(isA<ValidationError>()
                    .having((e) => e.code, 'code', 12)
                    .having((e) => e.message, 'message', 'This is an error.')
                    .having(
                        (e) => e.propertyName, 'propertyNamme', 'Property')),
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
