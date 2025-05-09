import 'package:logger/component.dart';

abstract interface class LoggerRepo {
  const LoggerRepo._();

  Future<void> saveLog(LogEntry log);
}
