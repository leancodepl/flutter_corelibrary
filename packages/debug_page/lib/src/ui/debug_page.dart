import 'package:debug_page/src/core/debug_page_controller.dart';
import 'package:debug_page/src/ui/logs_inspector/logs_inspector.dart';
import 'package:flutter/material.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({
    super.key,
    required DebugPageController controller,
  }) : _controller = controller;

  final DebugPageController _controller;

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  _DebugPageState();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (context) => LogsInspector(controller: widget._controller),
      ),
    );
  }
}
