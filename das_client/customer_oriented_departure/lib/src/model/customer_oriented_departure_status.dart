import 'package:logging/logging.dart';

final _log = Logger('CustomerOrientedDepartureStatus');

class CustomerOrientedDeparture {
  CustomerOrientedDeparture({required this.trainNumber, required this.status});

  final String trainNumber;
  final CustomerOrientedDepartureStatus status;

  @override
  String toString() {
    return 'CustomerOrientedDeparture{trainNumber: $trainNumber, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerOrientedDeparture &&
          runtimeType == other.runtimeType &&
          trainNumber == other.trainNumber &&
          status == other.status;

  @override
  int get hashCode => Object.hash(trainNumber, status);
}

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
