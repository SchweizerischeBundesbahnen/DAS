import 'package:das_client/logging/src/das_log_tree.dart';
import 'package:das_client/logging/src/log_service.dart';
import 'package:fimber/fimber.dart';

export 'package:das_client/logging/src/log_entry.dart';

class LoggingComponent {
  const LoggingComponent._();

  static LogTree createDasLogTree() {
    return DasLogTree(logService: LogService());
  }
}