import 'package:cqrs/src/cqrs_exception.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  group('CQRSException', () {
    final response = Response('', 401, reasonPhrase: 'Unauthorized');

    group('has correct fields values', () {
      test('with message present', () {
        final exception1 = CqrsException(response, 'This is a message.');

        expect(exception1.response, response);
        expect(exception1.message, 'This is a message.');
      });

      test('with message absent', () {
        final exception2 = CqrsException(response);

        expect(exception2.response, response);
        expect(exception2.message, isNull);
      });
    });

    test('correctly converts to String', () {
      final exception1 = CqrsException(response, 'This is a message.');

      expect(
        exception1.toString(),
        '''
This is a message.
Server returned a 401 Unauthorized status. Response body:
''',
      );
    });
  });
}
