import 'package:debug_page/src/models/request_log_record.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_overview_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_request_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/request_details_screen_response_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/share_request_log_dialog.dart';
import 'package:debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:flutter/material.dart';

class RequestDetailsRoute extends MaterialPageRoute<void> {
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: ShareButton(
          onPressed: () async => showDialog(
            context: context,
            builder: (context) => ShareRequestLogDialog(requestLog: requestLog),
          ),
        ),
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
