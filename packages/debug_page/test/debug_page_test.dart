import 'package:flutter_test/flutter_test.dart';

import 'package:debug_page/debug_page.dart';

void main() {
  test('sends a http request through logging http client and logs it',
      () async {
    final client = LoggingHttpClient();
    await client.get(Uri.parse('https://leancode.co/'));
    expect(client.logs, isNotEmpty);
  });
}
