import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/logger/level_color_extension.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/map_view.dart';
import 'package:leancode_debug_page/src/ui/logs_inspector/widgets/share_button.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

class LoggerLogDetailsRoute extends MaterialPageRoute<void> {
  LoggerLogDetailsRoute({required LogRecord logRecord})
      : super(
          builder: (context) => LoggerLogDetailsScreen(logRecord: logRecord),
        );
}

class LoggerLogDetailsScreen extends StatelessWidget {
  const LoggerLogDetailsScreen({
    super.key,
    required this.logRecord,
  });

  final LogRecord logRecord;

  @override
  Widget build(BuildContext context) {
    // Build the map with all available information
    final Map<Object, Object> logDetailsMap = {
      'Logger name': logRecord.loggerName,
      'Level': logRecord.level,
      'Time': logRecord.time,
      'Sequence number': logRecord.sequenceNumber,
    };

    // Add zone information if available
    if (logRecord.zone != Zone.root) {
      logDetailsMap['Zone'] = logRecord.zone.toString();
    }

    // Add error information if available
    if (logRecord.error != null) {
      logDetailsMap['Error'] = logRecord.error.toString();
    }

    // Build the widgets list
    final List<Widget> widgets = [
      MapView(map: logDetailsMap),
      const SizedBox(height: 16),
      if (logRecord.message.isNotEmpty) ...[
        const Text(
          'Message:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(logRecord.message),
        const SizedBox(height: 16),
      ],
    ];

    // Add stack trace if available
    if (logRecord.stackTrace != null) {
      widgets.addAll([
        const Text(
          'Stack trace:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              logRecord.stackTrace.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
      ]);
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: ShareButton(
        onPressed: () => Share.share(_shareLogDetails()),
      ),
      appBar: AppBar(
        title: const Text('Logger log details'),
        backgroundColor: logRecord.level.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }

  String _shareLogDetails() {
    final buffer = StringBuffer();
    buffer.writeln('Logger: ${logRecord.loggerName}');
    buffer.writeln('Level: ${logRecord.level}');
    buffer.writeln('Time: ${logRecord.time}');
    buffer.writeln('Sequence: ${logRecord.sequenceNumber}');
    
    if (logRecord.zone != Zone.root) {
      buffer.writeln('Zone: ${logRecord.zone}');
    }
    
    if (logRecord.error != null) {
      buffer.writeln('Error: ${logRecord.error}');
    }
    
    if (logRecord.message.isNotEmpty) {
      buffer.writeln('\nMessage:');
      buffer.writeln(logRecord.message);
    }
    
    if (logRecord.stackTrace != null) {
      buffer.writeln('\nStack trace:');
      buffer.writeln(logRecord.stackTrace);
    }
    
    return buffer.toString();
  }
}
