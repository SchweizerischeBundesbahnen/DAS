import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'battery_status_mock_test.mocks.dart';

@GenerateMocks([Battery])
void main() {
  late MockBattery mockBattery;

  setUp(() {
    mockBattery = MockBattery();
  });

  test('Test return battery level correctly', () async {
    when(mockBattery.batteryLevel).thenAnswer((_) async => 75);
    expect(await mockBattery.batteryLevel, equals(75));
  });

  test('Test detect charging state correctly', () async {
    when(mockBattery.batteryState).thenAnswer((_) async => BatteryState.charging);
    expect(await mockBattery.batteryState, equals(BatteryState.charging));
  });

  test('Test detect discharging state correctly', () async {
    when(mockBattery.batteryState).thenAnswer((_) async => BatteryState.discharging);
    expect(await mockBattery.batteryState, equals(BatteryState.discharging));
  });

  test('Test notify on battery state change', () async {
    final streamController = StreamController<BatteryState>();
    when(mockBattery.onBatteryStateChanged).thenAnswer((_) => streamController.stream);

    expectLater(mockBattery.onBatteryStateChanged, emitsInOrder([
      BatteryState.charging,
      BatteryState.discharging,
    ]));

    streamController.add(BatteryState.charging);
    streamController.add(BatteryState.discharging);

    await streamController.close();
  });
}