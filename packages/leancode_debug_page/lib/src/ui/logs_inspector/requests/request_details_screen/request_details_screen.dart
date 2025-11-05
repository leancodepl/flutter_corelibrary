import 'package:flutter/material.dart';
import 'package:leancode_debug_page/src/models/request_log_record.dart';
import 'package:leancode_debug_page/src/ui/debug_page_route.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_overview_tab.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_request_tab.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_response_tab.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/requests/request_details_screen/show_share_request_log_dialog.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:leancode_debug_page/src/ui/share_text_helper.dart';

class RequestDetailsRoute extends DebugPageRoute {
  RequestDetailsRoute(RequestLogRecord requestLog)
      : super(
          builder: (context) => RequestDetailsScreen(requestLog: requestLog),
        );
}

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({
    super.key,
    required this.requestLog,
  });

  final RequestLogRecord requestLog;

  Future<void> _shareRequest() async {
    final summary = await requestLog.toSummary(
      const RequestSharingConfiguration(includeResponse: true),
    );

    await shareTextWithEncoding(summary);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: ShareButton(onPressed: _shareRequest),
        appBar: AppBar(
          title: const Text('Request details'),
          bottom: const TabBar(
            tabs: [
              Text('Overview'),
              Text('Request'),
              Text('Response'),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TabBarView(
              children: [
                RequestDetailsScreenOverviewTab(requestLog: requestLog),
                RequestDetailsScreenRequestTab(requestLog: requestLog),
                RequestDetailsScreenResponseTab(requestLog: requestLog),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
