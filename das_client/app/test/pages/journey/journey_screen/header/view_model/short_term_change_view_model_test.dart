import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/short_term_change_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/short_term_change_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'short_term_change_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  late BehaviorSubject<Journey?> rxMockJourney;
  late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
  late ShortTermChangeViewModel testee;
  late FakeAsync testAsync;
  final List<dynamic> emitRegister = [];
  late StreamSubscription<ShortTermChangeModel?> modelSubscription;
  late MockJourneyTableViewModel mockJourneyTableViewModel;
  late MockJourneyPositionViewModel mockJourneyPositionViewModel;

  setUp(() {
    GetIt.I.registerSingleton<TimeConstants>(TimeConstants());
    fakeAsync((fakeAsync) {
      testAsync = fakeAsync;
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      mockJourneyTableViewModel = MockJourneyTableViewModel();
      mockJourneyPositionViewModel = MockJourneyPositionViewModel();
      when(mockJourneyTableViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      when(mockJourneyPositionViewModel.model).thenAnswer((_) => rxMockJourneyPosition.stream);
      testee = ShortTermChangeViewModel(
        journeyPositionViewModel: mockJourneyPositionViewModel,
        journeyTableViewModel: mockJourneyTableViewModel,
      );
      modelSubscription = testee.model.listen(emitRegister.add);
    });
  });

  tearDown(() {
    modelSubscription.cancel();
    emitRegister.clear();
    testee.dispose();
    rxMockJourneyPosition.close();
    rxMockJourney.close();
    GetIt.I.reset();
  });

  final _signalA = Signal(order: 50, kilometre: []);
  final _stopA = ServicePoint(name: 'Stop A', abbreviation: 'SA', locationCode: '', order: 100, kilometre: []);
  final _stopB = ServicePoint(name: 'Stop B', abbreviation: 'SB', locationCode: '', order: 500, kilometre: []);
  final _pointC = ServicePoint(
    name: 'ServicePoint C',
    abbreviation: 'SC',
    locationCode: '',
    order: 1000,
    kilometre: [],
    isStop: false,
  );
  final _stopD = ServicePoint(name: 'ServicePoint D', abbreviation: 'SD', locationCode: '', order: 1500, kilometre: []);

  test('modelValue_whenHasNoJourney_thenIsNoChanges', () {
    expect(testee.modelValue, equals(ShortTermChangeModel.noShortTermChanges()));
  });

  test('modelValue_whenHasJourneyWithNoChanges_thenIsNoChanges', () async {
    testAsync.run((_) async {
      rxMockJourney.add(Journey(metadata: Metadata(), data: []));
      await processStreams(fakeAsync: testAsync);
    });

    expect(testee.modelValue, equals(ShortTermChangeModel.noShortTermChanges()));
  });

  test('modelValue_whenSingleChangeAndPositionOnRouteStart_thenIsSingleChange', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(shortTermChanges: [Stop2PassChange(startOrder: 0, endOrder: 0, startData: _stopA)]),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      await processStreams(fakeAsync: testAsync);
    });

    final expectedChange = ShortTermChangeModel.singleShortTermChange(
      shortTermChangeType: ShortTermChangeType.stop2Pass,
      servicePointName: _stopA.name,
    );
    expect(testee.modelValue, equals(expectedChange));
    expect(emitRegister, hasLength(2));
    expect(emitRegister.last, equals(expectedChange));
  });

  test('modelValue_whenMultipleChangesAndPositionOnRouteStart_thenIsMultipleChanges', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              Stop2PassChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
              Pass2StopChange(startOrder: _stopD.order, endOrder: _stopD.order, startData: _stopD),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      await processStreams(fakeAsync: testAsync);
    });

    final expectedChange = ShortTermChangeModel.multipleShortTermChanges();
    expect(testee.modelValue, equals(expectedChange));
    expect(emitRegister, hasLength(2));
    expect(emitRegister.last, equals(expectedChange));
  });

  test('modelValue_whenPassedFirstChange_thenIsNoChange', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              Stop2PassChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _stopB));
      await processStreams(fakeAsync: testAsync);
    });

    final expectedMiddleChange = ShortTermChangeModel.singleShortTermChange(
      shortTermChangeType: ShortTermChangeType.stop2Pass,
      servicePointName: _stopA.name,
    );
    expect(testee.modelValue, equals(ShortTermChangeModel.noShortTermChanges()));
    expect(emitRegister, hasLength(3));
    expect(emitRegister[1], equals(expectedMiddleChange));
  });

  test('modelValue_whenSecondChangeInSightAndPassedFirst_thenIsSecondChange', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              Stop2PassChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
              Pass2StopChange(startOrder: _stopD.order, endOrder: _stopD.order, startData: _stopD),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _stopB));
      await processStreams(fakeAsync: testAsync);
    });

    expect(
      testee.modelValue,
      equals(
        ShortTermChangeModel.singleShortTermChange(
          shortTermChangeType: ShortTermChangeType.pass2Stop,
          servicePointName: _stopD.name,
        ),
      ),
    );
    expect(emitRegister, hasLength(3));
    expect(emitRegister[1], equals(ShortTermChangeModel.multipleShortTermChanges()));
  });

  test('modelValue_whenIsOnFirstChangeAndSecondInSight_thenIsFirstChange', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              Stop2PassChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
              Pass2StopChange(
                startOrder: _pointC.order,
                endOrder: _pointC.order,
                startData: _pointC,
              ),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _stopA));
      await processStreams(fakeAsync: testAsync);
    });

    final expectChange = ShortTermChangeModel.singleShortTermChange(
      shortTermChangeType: ShortTermChangeType.stop2Pass,
      servicePointName: _stopA.name,
    );
    expect(testee.modelValue, equals(expectChange));
    expect(emitRegister, hasLength(3));
    expect(emitRegister[1], equals(ShortTermChangeModel.multipleShortTermChanges()));
  });

  test('modelValue_whenHasTwoChangesInSight_thenIsCloserChange', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              Stop2PassChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
              Pass2StopChange(startOrder: _stopB.order, endOrder: _stopB.order, startData: _stopB),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _signalA));
      await processStreams(fakeAsync: testAsync);
    });

    final expectedChange = ShortTermChangeModel.singleShortTermChange(
      shortTermChangeType: ShortTermChangeType.stop2Pass,
      servicePointName: _stopA.name,
    );
    expect(testee.modelValue, equals(expectedChange));
    expect(emitRegister, hasLength(3));
    expect(emitRegister[1], equals(ShortTermChangeModel.multipleShortTermChanges()));
  });

  test('modelValue_whenHasTwoChangesInSightOnSameServicePoint_thenIsWithHigherPriority', () async {
    testAsync.run((_) async {
      rxMockJourney.add(
        Journey(
          metadata: Metadata(
            shortTermChanges: [
              EndDestinationChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
              Pass2StopChange(startOrder: _stopA.order, endOrder: _stopA.order, startData: _stopA),
            ],
          ),
          data: [_signalA, _stopA, _stopB, _pointC, _stopD],
        ),
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _signalA));
      await processStreams(fakeAsync: testAsync);
    });

    final expectedChange = ShortTermChangeModel.singleShortTermChange(
      shortTermChangeType: ShortTermChangeType.pass2Stop,
      servicePointName: _stopA.name,
    );
    expect(testee.modelValue, equals(expectedChange));
    expect(emitRegister, hasLength(3));
    expect(emitRegister[1], equals(ShortTermChangeModel.multipleShortTermChanges()));
  });

  // test('model_whenSingleShortTermChangeAndPositionAfterRouteStart_thenIsSingleShortTermChangeForDuration', () async {
  //   testAsync.run((_) async {
  //     rxMockJourney.add(
  //       Journey(
  //         metadata: Metadata(shortTermChanges: [Stop2PassChange(startOrder: 0, endOrder: 0, startData: _stopA)]),
  //         data: [_signalA, _stopA, _stopB, _pointC, _stopD],
  //       ),
  //     );
  //     rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: _signalA));
  //     await processStreams(fakeAsync: testAsync);
  //   });
  //
  //   final expectedChange = ShortTermChangeModel.singleShortTermChange(
  //     shortTermChangeType: ShortTermChangeType.stop2Pass,
  //     servicePointName: _stopA.name,
  //   );
  //   expect(testee.modelValue, equals(expectedChange));
  //   expect(emitRegister, hasLength(2));
  //   expect(emitRegister.last, equals(expectedChange));
  //
  //   // elapse duration
  //   testAsync.run((fakeAsync) {
  //     fakeAsync.elapse(Duration(seconds: GetIt.I.get<TimeConstants>().newShortTermChangesDisplaySeconds + 1));
  //     processStreams(fakeAsync: fakeAsync);
  //   });
  //
  //   expect(testee.modelValue, equals(ShortTermChangeModel.noShortTermChanges()));
  //   expect(emitRegister, hasLength(3));
  // });
}
