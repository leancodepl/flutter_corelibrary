import 'package:debug_page/src/models/request_log_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debug_page/debug_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final homeUrl = Uri.parse('https://leancode.co/');

  group('LoggingHttpClient', () {
    late LoggingHttpClient loggingHttpClient;

    setUp(() {
      loggingHttpClient = LoggingHttpClient();
    });

    test('send a http request through logging http client and log it',
        () async {
      await loggingHttpClient.get(homeUrl);

      expectLater(
        loggingHttpClient.logStream,
        emits(const TypeMatcher<List<RequestLogRecord>>()),
      );
    });
  });
}
