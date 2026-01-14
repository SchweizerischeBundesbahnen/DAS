import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/departure_authorization_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/model/departure_authorization_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'departure_authentication_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  group('DepartureAuthorizationViewModel', () {
    late BehaviorSubject<Journey?> rxMockJourney;
    late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
    late DepartureAuthorizationViewModel testee;
    final List<dynamic> emitRegister = [];
    late StreamSubscription<DepartureAuthorizationModel?> modelSubscription;
    late MockJourneyTableViewModel mockJourneyTableViewModel;

    setUp(() {
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      mockJourneyTableViewModel = MockJourneyTableViewModel();
      when(mockJourneyTableViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      testee = DepartureAuthorizationViewModel(
        journeyPositionStream: rxMockJourneyPosition.stream,
        journeyTableViewModel: mockJourneyTableViewModel,
      );
      modelSubscription = testee.model.listen(emitRegister.add);
    });

    tearDown(() {
      modelSubscription.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    test('constructor_whenCalled_thenSubscribesToStreams', () {
      expect(rxMockJourney.hasListener, isTrue);
      expect(rxMockJourneyPosition.hasListener, isTrue);
    });

    test('model_whenJourneyNull_thenAllValuesNull', () => expect(testee.modelValue, isNull));

    test('model_whenNoPosition_thenReturnsWithFirstServicePoint', () async {
      // ARRANGE
      rxMockJourney.add(_mockJourney);
      await _streamProcessing();

      // EXPECT
      expect(
        emitRegister.last,
        equals(DepartureAuthorizationModel(servicePoint: _stopA)),
      );
    });

    test('model_whenPositionOnServicePointStop_thenReturnsCurrentStop', () async {
      // ARRANGE
      rxMockJourney.add(_mockJourney);
      rxMockJourneyPosition.add(
        JourneyPositionModel(
          currentPosition: _stopB,
          previousStop: _stopB,
          nextStop: _stopD,
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(
        emitRegister.last,
        equals(DepartureAuthorizationModel(servicePoint: _stopB)),
      );
    });

    test('model_whenPositionOnServicePointWithoutStop_thenReturnsNextStop', () async {
      // ARRANGE
      rxMockJourney.add(_mockJourney);
      rxMockJourneyPosition.add(
        JourneyPositionModel(
          currentPosition: _passingPointC,
          previousStop: _stopB,
          nextStop: _stopD,
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(
        emitRegister.last,
        equals(DepartureAuthorizationModel(servicePoint: _stopD)),
      );
    });

    test('model_whenPositionOnFirstNonIntermediateSignalAfterStop_thenReturnsNextStop', () async {
      // ARRANGE
      rxMockJourney.add(_mockJourney);
      rxMockJourneyPosition.add(
        JourneyPositionModel(
          currentPosition: _intermediateSignalAfterStopB,
          previousStop: _stopB,
          nextStop: _stopD,
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(
        emitRegister.last,
        equals(DepartureAuthorizationModel(servicePoint: _stopB)),
      );
    });

    test('model_whenPositionOnIntermediateSignalAfterStop_thenReturnsCurrentStop', () async {
      // ARRANGE
      rxMockJourney.add(_mockJourney);
      rxMockJourneyPosition.add(
        JourneyPositionModel(
          currentPosition: _exitSignalAfterIntermediateSignalStopB,
          previousStop: _stopB,
          nextStop: _stopD,
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(
        emitRegister.last,
        equals(DepartureAuthorizationModel(servicePoint: _stopD)),
      );
    });
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

final _stopA = ServicePoint(name: 'Stop A', abbreviation: 'SA', order: 0, kilometre: []);
final _stopB = ServicePoint(name: 'Stop B', abbreviation: 'SB', order: 500, kilometre: []);
final _passingPointC = ServicePoint(
  name: 'ServicePoint C',
  abbreviation: 'SC',
  order: 1000,
  kilometre: [],
  isStop: false,
);
final _stopD = ServicePoint(name: 'ServicePoint D', abbreviation: 'SD', order: 1500, kilometre: []);
final _intermediateSignalAfterStopB = Signal(order: 600, kilometre: [], functions: [.intermediate]);
final _exitSignalAfterIntermediateSignalStopB = Signal(order: 700, kilometre: [], functions: [.exit]);

Journey get _mockJourney {
  return Journey(
    metadata: Metadata(),
    data: [
      _stopA,
      Signal(order: 100, kilometre: [], functions: [.exit]),
      Signal(order: 200, kilometre: [], functions: [.intermediate]),
      Signal(order: 300, kilometre: [], functions: [.entry]),
      _stopB,
      _intermediateSignalAfterStopB,
      _exitSignalAfterIntermediateSignalStopB,
      Signal(order: 800, kilometre: [], functions: [.intermediate]),
      Signal(order: 900, kilometre: [], functions: [.entry]),
      _passingPointC,
      Signal(order: 1100, kilometre: [], functions: [.exit]),
      Signal(order: 1200, kilometre: [], functions: [.intermediate]),
      Signal(order: 1300, kilometre: [], functions: [.entry]),
      _stopD,
    ],
  );
}
