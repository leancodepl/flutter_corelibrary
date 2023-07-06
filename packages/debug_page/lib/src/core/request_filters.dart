import 'package:debug_page/src/models/filter.dart';
import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/requests_tab_filters_menu.dart';

class RequestStatusFilter implements Filter<RequestLogRecord> {
  const RequestStatusFilter({required this.desiredStatus});

  final RequestStatus desiredStatus;

  @override
  bool filter(RequestLogRecord requestLogRecord) =>
      requestLogRecord.status == desiredStatus;
}

class RequestSearchFilter implements Filter<RequestLogRecord> {
  const RequestSearchFilter({
    required this.type,
    required this.phrase,
  });

  final RequestSearchType type;
  final String phrase;

  // TOOD: implement searching by body and other fields too
  @override
  bool filter(RequestLogRecord requestLogRecord) {
    if ([RequestSearchType.url, RequestSearchType.all].contains(type)) {
      final url = requestLogRecord.url.toString();

      if (!url.contains(phrase)) {
        return false;
      }
    }

    if ([RequestSearchType.body, RequestSearchType.all].contains(type)) {
      // TODO: What to do with the future?
    }

    return true;
  }
}
