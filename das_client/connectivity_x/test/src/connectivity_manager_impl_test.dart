import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_x/src/connection_check_service.dart';
import 'package:connectivity_x/src/connectivity_manager_impl.dart';
import 'package:connectivity_x/src/network_roaming_service.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'connectivity_manager_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Connectivity>(),
  MockSpec<NetworkRoamingService>(),
  MockSpec<ConnectionCheckService>(),
])
void main() {
  late MockConnectivity mockConnectivity;
  late MockNetworkRoamingService mockNetworkRoamingService;
  late MockConnectionCheckService mockConnectionCheckService;
  late StreamController<List<ConnectivityResult>> connectivityController;
  late ConnectivityManagerImpl testee;

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockNetworkRoamingService = MockNetworkRoamingService();
    mockConnectionCheckService = MockConnectionCheckService();
    testee = ConnectivityManagerImpl(
      connectivity: mockConnectivity,
      networkRoamingService: mockNetworkRoamingService,
      connectionCheckService: mockConnectionCheckService,
    );

    connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

    when(mockConnectivity.onConnectivityChanged).thenAnswer((_) => connectivityController.stream);
    when(mockNetworkRoamingService.isNetworkRoaming()).thenAnswer((_) async => false);
    when(mockConnectionCheckService.hasInternetConnection()).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await connectivityController.close();
  });

  test('isNetworkRoaming_whenConnectivityChanges_thenRequestsRoamingStateCheck', () async {
    // GIVEN WHEN
    connectivityController.add([ConnectivityResult.wifi]);
    await _drainAsyncWork();

    // THEN
    verify(mockNetworkRoamingService.isNetworkRoaming()).called(1);
    testee.dispose();
  });

  test('timer_whenPeriodicTimerTicks_thenRechecksConnectivityState', () {
    fakeAsync((async) {
      // GIVEN WHEN
      async.elapse(ConnectivityManagerImpl.connectivityCheckInterval);
      async.flushMicrotasks();

      // THEN
      verify(mockNetworkRoamingService.isNetworkRoaming()).called(1);
      testee.dispose();
    });
  });

  test('isConnected_whenHasInternetConnectionReturnsTrue_thenEmitsTrueAndSetsLastConnected', () async {
    // GIVEN
    final timeBeforeStart = DateTime.now();
    final emittedValues = <bool>[];
    final subscription = testee.isConnected.listen(emittedValues.add);

    // WHEN
    connectivityController.add([ConnectivityResult.wifi]);
    await _drainAsyncWork();

    // THEN
    expect(emittedValues, contains(true));
    expect(testee.lastConnected, isNotNull);
    expect(testee.lastConnected?.isAfter(timeBeforeStart), isTrue);
    await subscription.cancel();
  });

  test('isConnected_whenHasInternetConnectionReturnsFalse_thenEmitsFalseAndLastConnectedStaysNull', () async {
    // GIVEN
    when(mockConnectionCheckService.hasInternetConnection()).thenAnswer((_) async => false);
    final emittedValues = <bool>[];
    final subscription = testee.isConnected.listen(emittedValues.add);

    // WHEN
    connectivityController.add([ConnectivityResult.wifi]);
    await _drainAsyncWork();

    // THEN
    expect(emittedValues, isNot(contains(true)));
    expect(testee.lastConnected, isNull);
    await subscription.cancel();
  });

  test('isWifiActive_whenConnectivityResultsContainWifi_thenEmitsTrue', () async {
    // GIVEN
    final emittedValues = <bool>[];
    final subscription = testee.isWifiActive.listen(emittedValues.add);

    // WHEN
    connectivityController.add([ConnectivityResult.wifi]);
    await _drainAsyncWork();

    // THEN
    expect(emittedValues, contains(true));
    expect(testee.isWifiActiveValue, isTrue);
    await subscription.cancel();
  });

  test('isWifiActive_whenConnectivityResultsDoNotContainWifi_thenStaysFalse', () async {
    // GIVEN
    final emittedValues = <bool>[];
    final subscription = testee.isWifiActive.listen(emittedValues.add);

    // WHEN
    connectivityController.add([ConnectivityResult.mobile]);
    await _drainAsyncWork();

    // THEN
    expect(emittedValues, isNot(contains(true)));
    expect(testee.isWifiActiveValue, isFalse);
    await subscription.cancel();
  });

  test('isNetworkRoaming_whenServiceReturnsTrue_thenEmitsTrue', () async {
    // GIVEN
    when(mockNetworkRoamingService.isNetworkRoaming()).thenAnswer((_) async => true);
    final emittedValues = <bool>[];
    final subscription = testee.isNetworkRoaming.listen(emittedValues.add);

    // WHEN
    connectivityController.add([ConnectivityResult.mobile]);
    await _drainAsyncWork();

    // THEN
    expect(emittedValues, contains(true));
    await subscription.cancel();
  });
}

Future<void> _drainAsyncWork([int cycles = 5]) async {
  for (var i = 0; i < cycles; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
