import 'package:customer_oriented_departure/component.dart';

abstract class CustomerOrientedDepartureRepository {
  const CustomerOrientedDepartureRepository._();

  Stream<CustomerOrientedDepartureStatus> get status;

  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String deviceId,
    required DateTime journeyEndTime,
    required bool isDriver,
  });

  Future<bool> unsubscribe({
    required String evu,
    required String trainNumber,
    required String deviceId,
    required DateTime journeyEndTime,
    required bool isDriver,
  });

  void dispose();
}
