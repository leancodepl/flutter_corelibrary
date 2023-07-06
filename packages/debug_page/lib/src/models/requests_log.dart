import 'package:debug_page/src/models/request_log_record.dart';

class RequestsLog {
  const RequestsLog({required List<RequestLogRecord> logs}) : _logs = logs;

  final List<RequestLogRecord> _logs;
  List<RequestLogRecord> get logs => List.unmodifiable(_logs);
}
