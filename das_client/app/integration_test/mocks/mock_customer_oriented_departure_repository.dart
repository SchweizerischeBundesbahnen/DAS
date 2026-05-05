import 'package:customer_oriented_departure/component.dart';
import 'package:rxdart/rxdart.dart';

// TODO: Use Ux testing events instead?
class MockCustomerOrientedDepartureRepository implements CustomerOrientedDepartureRepository {
  final _rxStatus = BehaviorSubject<CustomerOrientedDepartureStatus>();

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
    // unused
    return true;
  }

  @override
  Future<bool> unsubscribe() async {
    // unused
    return true;
  }

  @override
  void dispose() {
    _rxStatus.close();
  }
}
