import 'package:cqrs/src/transport_types.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class QueryImpl extends Query<void> with Fake {}

class CommandImpl extends Command with Fake {}

void main() {
  group('Query', () {
    test('has correct path prefix', () {
      expect(QueryImpl().pathPrefix, 'query');
    });
  });

  group('Command', () {
    test('has correct path prefix', () {
      expect(CommandImpl().pathPrefix, 'command');
    });
  });
}
