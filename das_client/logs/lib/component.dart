import 'package:logs/src/das_log_tree.dart';
import 'package:logs/src/log_service.dart';
import 'package:fimber/fimber.dart';

export 'package:logs/src/log_entry.dart';

class LogsComponent {
  const LogsComponent._();

  static LogTree createDasLogTree() {
    return DasLogTree(logService: LogService());
  }
}
