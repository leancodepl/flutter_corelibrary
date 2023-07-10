import 'dart:async';

import 'package:debug_page/src/core/log_gatherer.dart';
import 'package:logging/logging.dart';

class LoggerListener implements LogGatherer<LogRecord> {
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

  void dispose() {
    _subscription?.cancel();
  }
}
