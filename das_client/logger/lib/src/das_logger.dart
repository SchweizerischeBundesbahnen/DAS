import 'package:logging/logging.dart';

abstract class DASLogger {
  void call(LogRecord record);

  set useSferaMock(bool value);
}
