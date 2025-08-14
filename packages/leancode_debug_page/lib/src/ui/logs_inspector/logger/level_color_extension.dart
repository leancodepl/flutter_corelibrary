import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

extension ColorExtension on Level {
  Color color(BuildContext context) => switch (Theme.of(context).brightness) {
        Brightness.dark => switch (this) {
            Level.FINE || Level.FINER || Level.FINEST => Colors.green.shade700,
            Level.CONFIG || Level.INFO => Colors.lightGreen.shade700,
            Level.WARNING => Colors.orange.shade700,
            Level.SEVERE => Colors.red.shade600,
            _ => Colors.grey.shade700,
          },
        Brightness.light => switch (this) {
            Level.FINE || Level.FINER || Level.FINEST => Colors.green,
            Level.CONFIG || Level.INFO => Colors.lightGreen,
            Level.WARNING => Colors.orange,
            Level.SEVERE => Colors.red,
            _ => Colors.grey,
          },
      };
}
