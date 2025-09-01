import 'package:logger/src/log_level.dart';

class LogEntry {
  LogEntry(this.message, this.level, this.metadata) : time = DateTime.now().millisecondsSinceEpoch / 1000;

  final double time;
  final String message;
  final LogLevel level;
  final Map<String, dynamic> metadata;
}
