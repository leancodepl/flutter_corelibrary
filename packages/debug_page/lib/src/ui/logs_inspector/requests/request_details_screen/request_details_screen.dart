import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/overview_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/request_tab.dart';
import 'package:debug_page/src/ui/logs_inspector/requests/request_details_screen/response_tab.dart';
import 'package:flutter/material.dart';

class RequestDetailsRoute extends MaterialPageRoute<void> {
  RequestDetailsRoute(RequestLog requestLog)
      : super(
          builder: (context) => RequestDetailsScreen(requestLog: requestLog),
        );
}

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({
    super.key,
    required this.requestLog,
  });

  final RequestLog requestLog;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                OverviewTab(requestLog: requestLog),
                RequestTab(requestLog: requestLog),
                ResponseTab(requestLog: requestLog),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
