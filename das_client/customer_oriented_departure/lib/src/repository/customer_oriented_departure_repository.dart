import 'package:customer_oriented_departure/component.dart';

abstract class CustomerOrientedDepartureRepository {
  const CustomerOrientedDepartureRepository._();

  Stream<CustomerOrientedDeparture> get customerOrientedDeparture;

  /// Subscribes to customer oriented departure updates for the given train.
  ///
  /// [journeyEndTime] is set to define the end of the subscription. If null, a default value is used.
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime? journeyEndTime,
    required bool isDriver,
  });

  /// Unsubscribes from the current subscription if there is any.
  Future<bool> unsubscribe();

  void dispose();
}
