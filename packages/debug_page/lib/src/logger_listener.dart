import 'dart:async';

import 'package:logging/logging.dart';

class LoggerListener {
  final _logController = StreamController<List<LogRecord>>.broadcast();
  final List<LogRecord> _logs = [];

  Stream<List<LogRecord>> get logStream => _logController.stream;
  List<LogRecord> get logs => List.unmodifiable(_logs);

  StreamSubscription<LogRecord>? _subscription;

  LoggerListener() {
    _subscription = Logger.root.onRecord.listen((record) {
      _logController.add(_logs..add(record));
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
