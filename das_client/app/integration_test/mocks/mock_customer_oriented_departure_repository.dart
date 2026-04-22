import 'package:customer_oriented_departure/component.dart';

class MockCustomerOrientedDepartureRepository implements CustomerOrientedDepartureRepository {
  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  }) async {
    // unused
    return true;
  }

  @override
  Future<bool> unsubscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  }) async {
    // unused
    return true;
  }
}
