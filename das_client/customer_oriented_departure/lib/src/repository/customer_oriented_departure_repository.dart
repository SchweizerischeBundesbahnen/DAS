abstract class CustomerOrientedDepartureRepository {
  const CustomerOrientedDepartureRepository._();

  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  });

  Future<bool> unsubscribe({
    required String evu,
    required String trainNumber,
    required String pushToken,
    required String deviceId,
    required String messageId,
    required DateTime expiresAt,
    required bool isDriver,
  });
}
