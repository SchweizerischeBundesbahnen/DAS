import 'package:customer_oriented_departure/component.dart';

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
