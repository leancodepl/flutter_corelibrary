import 'package:logging/logging.dart';

extension FormattingExtension on LogRecord {
  String format() => '$loggerName ($level): $message';
}
