import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';

class MockCustomerOrientedDepartureRepository implements CustomerOrientedDepartureRepository {
  int unsubscribeCallCount = 0;
  Set<String> subscribedTrainNumbers = {};

  final _rxStatus = BehaviorSubject<CustomerOrientedDeparture>();

  void emitStatus(CustomerOrientedDeparture status) => _rxStatus.add(status);

  @override
  Stream<CustomerOrientedDeparture> get customerOrientedDeparture => _rxStatus.stream;

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
    final previousTrainNumber = _rxStatus.valueOrNull?.trainNumber;
    if (previousTrainNumber != null) {
      _rxStatus.add(CustomerOrientedDeparture(trainNumber: previousTrainNumber, status: .departure));
    }
    unsubscribeCallCount = 0;
    subscribedTrainNumbers = {};
  }
}
