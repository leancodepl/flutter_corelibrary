import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/ui/logs_inspector.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({
    super.key,
    required LoggingHttpClient loggingHttpClient,
  }) : _loggingHttpClient = loggingHttpClient;

  final LoggingHttpClient _loggingHttpClient;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => LogsInspector(
          loggingHttpClient: _loggingHttpClient,
        ),
      ),
    );
  }
}
