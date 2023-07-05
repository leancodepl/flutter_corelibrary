import 'package:debug_page/src/ui/logs_inspector/logger/level_color_extension.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_log_details_screen/logger_log_details_screen.dart';
import 'package:debug_page/src/ui/typography.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class LoggerLogTile extends StatelessWidget {
  const LoggerLogTile({
    super.key,
    required this.log,
  });

  final LogRecord log;

  String _formatLog(LogRecord log) {
    return '${log.loggerName} (${log.level}): ${log.message}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: log.level.color,
      onTap: () => Navigator.of(context).push(
        LoggerLogDetailsRoute(logRecord: log),
      ),
      title: Text(
        _formatLog(log),
        style: DebugPageTypography.medium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
