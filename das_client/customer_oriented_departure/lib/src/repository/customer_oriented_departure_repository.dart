import 'package:customer_oriented_departure/component.dart';

abstract class CustomerOrientedDepartureRepository {
  const CustomerOrientedDepartureRepository._();

  Stream<CustomerOrientedDeparture> get customerOrientedDeparture;

  /// Checks if there was a new status received and publishes it over [customerOrientedDeparture]
  ///
  /// This can happen when the app is in the background and a message was received.
  void requestLatestStatus();

  /// Subscribes to customer oriented departure updates for the given train.
  ///
  /// [journeyEndTime] is set to define the end of the subscription.
  /// If null, default value [CustomerOrientedDepartureRepositoryImpl._defaultExpireDuration] is used.
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
