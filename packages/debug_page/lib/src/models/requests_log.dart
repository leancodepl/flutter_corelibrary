import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';

abstract class IRequestFilter {
  bool filter(RequestLogRecord requestLogRecord);
}

class RequestStatusFilter implements IRequestFilter {
  const RequestStatusFilter({required this.desiredStatus});

  final RequestStatus desiredStatus;

  @override
  bool filter(RequestLogRecord requestLogRecord) =>
      requestLogRecord.status == desiredStatus;
}

class RequestSearchFilter implements IRequestFilter {
  const RequestSearchFilter({
    required this.type,
    required this.phrase,
  });

  final SearchType type;
  final String phrase;

  // TOOD: implement searching by body and other fields too
  @override
  bool filter(RequestLogRecord requestLogRecord) {
    if ([SearchType.url, SearchType.all].contains(type)) {
      final url = requestLogRecord.url.toString();

      if (!url.contains(phrase)) {
        return false;
      }
    }

    if ([SearchType.body, SearchType.all].contains(type)) {
      // TODO: What to do with the future?
    }

    return true;
  }
}

class RequestsLog {
  const RequestsLog({required List<RequestLogRecord> logs}) : _logs = logs;

  final List<RequestLogRecord> _logs;

  List<RequestLogRecord> getFilteredLogs({
    List<IRequestFilter> filters = const [],
  }) {
    return _logs
        .where((log) => filters.every((filter) => filter.filter(log)))
        .toList();
  }
}
