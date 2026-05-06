import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';

class MockCustomerOrientedDepartureRepository implements CustomerOrientedDepartureRepository {
  int unsubscribeCallCount = 0;
  Set<String> subscribedTrainNumbers = {};

  final _rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>.seeded(.departure);

  void emitStatus(CustomerOrientedDepartureStatus status) => _rxStatus.add(status);

  @override
  Stream<CustomerOrientedDepartureStatus> get status => _rxStatus.stream;

  @override
  Future<bool> subscribe({
    required String evu,
    required String trainNumber,
    required DateTime? journeyEndTime,
    required bool isDriver,
  }) async {
    subscribedTrainNumbers.add(trainNumber);
    return true;
  }

  @override
  Future<bool> unsubscribe() async {
    unsubscribeCallCount++;
    return true;
  }

  @override
  void dispose() {
    _rxStatus.close();
  }

  void reset() {
    _rxStatus.add(.departure);
    unsubscribeCallCount = 0;
    subscribedTrainNumbers = {};
  }
}
