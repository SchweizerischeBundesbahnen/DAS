import 'package:logging/logging.dart';

abstract class DASLogger {
  void call(LogRecord record);

  set connectedToTmsVad(bool value);
}
