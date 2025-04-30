import 'package:logger/src/das_log_tree.dart';
import 'package:logger/src/log_service.dart';
import 'package:fimber/fimber.dart';

export 'package:logger/src/log_entry.dart';

class LoggerComponent {
  const LoggerComponent._();

  static LogTree createDasLogTree() {
    return DasLogTree(logService: LogService());
  }
}
