import 'package:logger/src/log_level.dart';

class LogEntry(
  final String message,
  final LogLevel level,
  final Map<String, dynamic> metadata,
) {
  this : time = DateTime.now().millisecondsSinceEpoch / 1000;

  final double time;
}
