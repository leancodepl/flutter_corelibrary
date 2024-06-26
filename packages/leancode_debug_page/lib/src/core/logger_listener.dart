import 'dart:async';

import 'package:leancode_debug_page/src/models/log_gatherer.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class LoggerListener implements LogGatherer<LogRecord> {
  LoggerListener() {
    _subscription = Logger.root.onRecord.listen(
      (record) {
        _logsController.add(logs..add(record));
      },
    );
  }

  final _logsController = BehaviorSubject<List<LogRecord>>.seeded([]);

  @override
  Stream<List<LogRecord>> get logStream => _logsController.stream;
  @override
  List<LogRecord> get logs => _logsController.value;

  StreamSubscription<LogRecord>? _subscription;

  void dispose() {
    _subscription?.cancel();
  }
}
