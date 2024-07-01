import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:leancode_debug_page/src/core/logger_listener.dart';
import 'package:leancode_debug_page/src/core/logging_http_client.dart';
import 'package:leancode_debug_page/src/models/filter.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shake/shake.dart';

bool get _isMobile =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

class DebugPageController {
  DebugPageController({
    this.showEntryButton = false,
    this.showOnShake = true,
    this.ignoredBasePath,
    required this.loggingHttpClient,
  }) : loggerListener = LoggerListener() {
    requestsFilters = ValueNotifier([]);
    _sourceRequestsStreamSubscription = loggingHttpClient.logStream.listen(
      _updateRequestsStream,
    );
    requestsFilters.addListener(
      () => _updateRequestsStream(
        loggingHttpClient.logs,
      ),
    );

    loggerFilters = ValueNotifier([]);
    _sourceLoggerLogsStreamSubscription = loggerListener.logStream.listen(
      _updateLoggerLogsStream,
    );
    loggerFilters.addListener(
      () => _updateLoggerLogsStream(loggerListener.logs),
    );

    // Platform check is necessary due shake package dependency on an obsolete
    // version of sensors_plus. Without the check, an exception is thrown on
    // platforms where accelerometer is not available.
    if (showOnShake && _isMobile) {
      _shakeDetector = ShakeDetector.autoStart(
        shakeThresholdGravity: 4,
        onPhoneShake: () => visible.value = true,
      );
    }
  }

  final bool showEntryButton;
  final bool showOnShake;

  final String? ignoredBasePath;

  final LoggingHttpClient loggingHttpClient;
  final LoggerListener loggerListener;

  ShakeDetector? _shakeDetector;

  final visible = ValueNotifier(false);

  late ValueNotifier<List<Filter<RequestLogRecord>>> requestsFilters;
  late ValueNotifier<List<Filter<LogRecord>>> loggerFilters;

  late StreamSubscription<List<RequestLogRecord>>
      _sourceRequestsStreamSubscription;
  final _requestsLogController = BehaviorSubject<List<RequestLogRecord>>();
  List<RequestLogRecord> get requestsLogs => _requestsLogController.value;
  Stream<List<RequestLogRecord>> get requestsLogStream =>
      _requestsLogController.stream;

  Future<void> _updateRequestsStream(List<RequestLogRecord> source) async {
    final filtered = await requestsFilters.value.apply(source);
    _requestsLogController.add(filtered);
  }

  late StreamSubscription<List<LogRecord>> _sourceLoggerLogsStreamSubscription;
  final _loggerLogController = BehaviorSubject<List<LogRecord>>();
  List<LogRecord> get loggerLogs => _loggerLogController.value;
  Stream<List<LogRecord>> get loggerLogStream => _loggerLogController.stream;

  Future<void> _updateLoggerLogsStream(List<LogRecord> source) async {
    final filtered = await loggerFilters.value.apply(source);
    _loggerLogController.add(filtered);
  }

  void dispose() {
    loggerListener.dispose();

    _shakeDetector?.stopListening();

    visible.dispose();

    _sourceRequestsStreamSubscription.cancel();
    requestsFilters.dispose();

    _sourceLoggerLogsStreamSubscription.cancel();
    loggerFilters.dispose();
  }
}
