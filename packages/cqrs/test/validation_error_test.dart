import 'package:cqrs/src/command_result.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationError', () {
    test('has correct fields values', () {
      const error = ValidationError(123, 'Test message', 'SomeProperty');

      expect(error.code, 123);
      expect(error.message, 'Test message');
      expect(error.propertyName, 'SomeProperty');
    });

    test('returns correct string value', () {
      const error = ValidationError(1337, 'Some message', 'SomeProperty');

      expect(error.toString(), '[SomeProperty] 1337: Some message');
    });

    test('is correctly deserialized from JSON', () {
      final error = ValidationError.fromJson({
        'ErrorCode': 128,
        'ErrorMessage': 'Some other message',
        'PropertyName': 'Property',
      });

      expect(error.code, 128);
      expect(error.message, 'Some other message');
      expect(error.propertyName, 'Property');
    });

    test('is correctly serialized to JSON', () {
      final json = ValidationError.fromJson({
        'ErrorCode': 128,
        'ErrorMessage': 'Some other message',
        'PropertyName': 'Property',
      }).toJson();

      expect(json['ErrorCode'], 128);
      expect(json['ErrorMessage'], 'Some other message');
      expect(json['PropertyName'], 'Property');
    });
  });
}
