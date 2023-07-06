import 'package:debug_page/src/ui/logs_inspector/logger/level_color_extension.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/map_view.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

class LoggerLogDetailsRoute extends MaterialPageRoute<void> {
  LoggerLogDetailsRoute({required LogRecord logRecord})
      : super(
          builder: (context) => LoggerLogDetailsScreen(logRecord: logRecord),
        );
}

class LoggerLogDetailsScreen extends StatelessWidget {
  const LoggerLogDetailsScreen({
    super.key,
    required this.logRecord,
  });

  final LogRecord logRecord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ShareButton(
        onPressed: () => Share.share(logRecord.message),
      ),
      appBar: AppBar(
        title: const Text('Logger log details'),
        backgroundColor: logRecord.level.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MapView(
              map: {
                'Logger name': logRecord.loggerName,
                'Level': logRecord.level,
                'Time': logRecord.time
              },
            ),
            const SizedBox(height: 16),
            Text(logRecord.message),
          ],
        ),
      ),
    );
  }
}
