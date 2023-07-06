import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/ui/logs_inspector/logger/logger_tab_filters_menu.dart';
import 'package:logging/logging.dart';

class LoggerLevelFilter implements Filter<LogRecord> {
  const LoggerLevelFilter({required this.desiredLevel});

  final Level desiredLevel;

  @override
  Future<bool> filter(LogRecord logRecord) async {
    if (desiredLevel == Level.FINE) {
      return [Level.FINE, Level.FINER, Level.FINEST].contains(logRecord.level);
    }

    return logRecord.level == desiredLevel;
  }
}

class LoggerSearchFilter implements Filter<LogRecord> {
  const LoggerSearchFilter({
    required this.type,
    required this.phrase,
  });

  final LogSearchType type;
  final String phrase;

  @override
  Future<bool> filter(LogRecord logRecord) async {
    bool? loggerName;
    bool? message;

    if ([LogSearchType.loggerName, LogSearchType.all].contains(type)) {
      loggerName = logRecord.loggerName.contains(phrase);
    }

    if ([LogSearchType.logMessage, LogSearchType.all].contains(type)) {
      message = logRecord.message.contains(phrase);
    }

    return switch (type) {
      LogSearchType.loggerName when loggerName == true => true,
      LogSearchType.logMessage when message == true => true,
      LogSearchType.all when loggerName == true || message == true => true,
      _ => false,
    };
  }
}
