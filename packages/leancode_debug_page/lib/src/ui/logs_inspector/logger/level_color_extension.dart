import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

extension ColorExtension on Level {
  Color get color {
    return switch (this) {
      Level.FINE || Level.FINER || Level.FINEST => Colors.green,
      Level.CONFIG || Level.INFO => Colors.lightGreen,
      Level.WARNING => Colors.orange,
      Level.SEVERE => Colors.red,
      _ => Colors.grey,
    };
  }
}
