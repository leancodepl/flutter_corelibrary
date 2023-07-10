import 'dart:async';

import 'package:logging/logging.dart';

class LoggerListener {
  LoggerListener() {
    _subscription = Logger.root.onRecord.listen(
      (record) {
        _logsController.add(_logs..add(record));
      },
    );
  }

  final _logsController = StreamController<List<LogRecord>>.broadcast();
  final List<LogRecord> _logs = [];

  Stream<List<LogRecord>> get logStream => _logsController.stream;
  List<LogRecord> get logs => List.unmodifiable(_logs);

  StreamSubscription<LogRecord>? _subscription;

  void dispose() {
    _subscription?.cancel();
  }
}
