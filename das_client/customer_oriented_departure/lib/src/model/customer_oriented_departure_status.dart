import 'package:logging/logging.dart';

final _log = Logger('CustomerOrientedDepartureStatus');

enum CustomerOrientedDepartureStatus {
  wait,
  ready,
  departure,
  call,
  ;

  static CustomerOrientedDepartureStatus? from(String value) {
    final status = values.where((status) => status.name.toLowerCase() == value.toLowerCase()).firstOrNull;
    if (status == null) {
      _log.warning('Received unknown status $value');
    }
    return status;
  }
}
