import 'package:flutter/material.dart';
import 'package:lean_analytics/lean_analytics.dart';
import 'package:provider/provider.dart';

class FirebaseAnalyticsWidget extends StatelessWidget {
  const FirebaseAnalyticsWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final analytics = FirebaseLeanAnalytics();

    return Provider<LeanAnalytics>.value(
      value: analytics,
      child: child,
    );
  }
}
