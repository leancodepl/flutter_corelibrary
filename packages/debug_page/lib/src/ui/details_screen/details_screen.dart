import 'package:debug_page/src/request_log.dart';
import 'package:debug_page/src/ui/details_screen/map_view.dart';
import 'package:debug_page/src/ui/details_screen/overview_tab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsRoute extends MaterialPageRoute<void> {
  DetailsRoute(RequestLog requestLog)
      : super(
          builder: (context) => DetailsScreen(requestLog: requestLog),
        );
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.requestLog,
  });

  final RequestLog requestLog;

  static const _headerTextStyle = TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Details'),
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Headers', style: _headerTextStyle),
                      const SizedBox(height: 8),
                      MapView(map: requestLog.requestHeaders),
                      const SizedBox(height: 16),
                      const Text(
                        'Body',
                        style: _headerTextStyle,
                      ),
                      FutureBuilder(
                        future: requestLog.body,
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '');
                        },
                      ),
                    ],
                  ),
                ),
                MapView(map: requestLog.responseHeaders),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
