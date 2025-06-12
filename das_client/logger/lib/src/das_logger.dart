import 'package:logging/logging.dart';

abstract class DasLogger {
  void call(LogRecord record);
}
