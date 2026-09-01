import 'package:logger/component.dart';

abstract interface class const LoggerRepo._() {
  Future<void> saveLog(LogEntry log);
}
