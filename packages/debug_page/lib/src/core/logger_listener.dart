import 'dart:async';

import 'package:debug_page/src/core/log_gatherer.dart';
import 'package:logging/logging.dart';

extension FormattingExtension on LogRecord {
  String format() => '$loggerName ($level): $message';
}

class LogSharingConfiguration implements SummaryConfiguration {}

class LoggerListener
    implements LogGatherer<LogRecord, LogSharingConfiguration> {
  LoggerListener() {
    _subscription = Logger.root.onRecord.listen(
      (record) {
        _logsController.add(_logs..add(record));
      },
    );
  }

  final _logsController = StreamController<List<LogRecord>>.broadcast();
  final List<LogRecord> _logs = [];

  @override
  Stream<List<LogRecord>> get logStream => _logsController.stream;
  @override
  List<LogRecord> get logs => List.unmodifiable(_logs);

  StreamSubscription<LogRecord>? _subscription;

  @override
  Future<String> getSummary(LogSharingConfiguration configuration) async {
    final buffer = StringBuffer();

    for (final logRecord in logs) {
      buffer.writeln(logRecord.format());
      buffer.writeln(LogGatherer.recordsSeparator);
    }

    return buffer.toString();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
