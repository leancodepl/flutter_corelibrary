import 'package:cqrs/src/command_result.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationError', () {
    test('has correct fields values', () {
      const error = ValidationError(123, 'Test message');

      expect(error.code, 123);
      expect(error.message, 'Test message');
    });

    test('returns correct string value', () {
      const error = ValidationError(1337, 'Some message');

      expect(error.toString(), '1337: Some message');
    });

    test('is correctly deserialized from JSON', () {
      final error = ValidationError.fromJson({
        'ErrorCode': 128,
        'ErrorMessage': 'Some other message',
      });

      expect(error.code, 128);
      expect(error.message, 'Some other message');
    });
  });
}
