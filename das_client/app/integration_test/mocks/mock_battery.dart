import 'package:battery_plus/battery_plus.dart';
import 'package:rxdart/rxdart.dart';

class MockBattery implements Battery {
  var currentBatteryLevel = 10;
  var currentBatteryState = BatteryState.charging;
  var batteryStateSubject = BehaviorSubject.seeded(BatteryState.charging);

  @override
  Future<int> get batteryLevel => Future.value(currentBatteryLevel);

  @override
  Future<BatteryState> get batteryState => Future.value(currentBatteryState);

  @override
  Future<bool> get isInBatterySaveMode => Future.value(false);

  @override
  Stream<BatteryState> get onBatteryStateChanged => batteryStateSubject.stream;
}
