import 'package:logging/logging.dart';

final _log = Logger('CustomerOrientedDepartureStatus');

// TODO: Status not enough as we need to check for right train
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
