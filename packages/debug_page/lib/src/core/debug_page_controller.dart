import 'dart:async';

import 'package:debug_page/debug_page.dart';
import 'package:debug_page/src/core/logger_listener.dart';
import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shake/shake.dart';

class DebugPageController {
  DebugPageController({
    required this.loggingHttpClient,
    this.loggerFilters = const [],
    this.requestsFilters = const [],
  }) : loggerListener = LoggerListener() {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 4,
      onPhoneShake: () => visible.value = true,
    );
  }

  final LoggingHttpClient loggingHttpClient;
  final LoggerListener loggerListener;
  ShakeDetector? _shakeDetector;

  final visible = ValueNotifier(false);

  List<Filter<RequestLogRecord>> requestsFilters;
  List<Filter<LogRecord>> loggerFilters;

  List<RequestLogRecord> get requestsLogs => loggingHttpClient.logs;
  Stream<List<RequestLogRecord>> get requestsLogStream {
    return loggingHttpClient.logStream.asyncMap(
      (event) => requestsFilters.apply(event),
    );
  }

  List<LogRecord> get loggerLogs => loggerListener.logs;
  Stream<List<LogRecord>> get loggerLogStream {
    return loggerListener.logStream.asyncMap(
      (event) => loggerFilters.apply(event),
    );
  }

  void dispose() {
    loggerListener.dispose();
    _shakeDetector?.stopListening();
    visible.dispose();
  }
}
