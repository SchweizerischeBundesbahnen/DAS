import 'package:das_client/logging/src/log_level.dart';

class LogEntry {
  LogEntry(this.message, this.level, this.metadata)
      : time = DateTime.now().millisecondsSinceEpoch / 1000,
        source = 'das_client';

  final double time;
  final String source;
  final String message;
  final LogLevel level;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
        'time': time,
        'source': source,
        'message': message,
        'level': level.name,
        'metadata': metadata,
      };

  LogEntry.fromJson(Map<String, dynamic> json)
      : time = json['time'],
        source = json['source'],
        message = json['message'],
        level = LogLevel.values.firstWhere((element) => element.name == json['level']),
        metadata = json['metadata'];
}
