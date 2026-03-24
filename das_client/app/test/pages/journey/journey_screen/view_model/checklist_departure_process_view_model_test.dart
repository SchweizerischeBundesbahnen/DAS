import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'checklist_departure_process_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<RuFeatureProvider>(),
])
void main() {
  group('ChecklistDepartureProcessViewModel', () {
    late ChecklistDepartureProcessViewModel testee;
    late MockJourneyViewModel mockJourneyViewModel;
    late MockJourneyPositionViewModel mockJourneyPositionViewModel;
    late MockRuFeatureProvider mockRuFeatureProvider;

    late BehaviorSubject<Journey?> journeySubject;
    late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;

    late List<bool> chronographRegister;
    late List<bool> departureButtonRegister;
    late FakeAsync testAsync;

    final servicePointA = ServicePoint(name: 'A', abbreviation: '', locationCode: '', order: 0, kilometre: []);
    final entrySignal = Signal(order: 1, kilometre: [], functions: [SignalFunction.entry]);
    final exitSignal = Signal(order: 2, kilometre: [], functions: [SignalFunction.exit]);
    final intermediateSignal = Signal(order: 3, kilometre: [], functions: [SignalFunction.intermediate]);
    final blockSignal = Signal(order: 4, kilometre: [], functions: [SignalFunction.block]);

    void setupTestee() {
      fakeAsync((fakeAsync) {
        testAsync = fakeAsync;

        testee = ChecklistDepartureProcessViewModel(
          journeyPositionViewModel: mockJourneyPositionViewModel,
          ruFeatureProvider: mockRuFeatureProvider,
          journeyViewModel: mockJourneyViewModel,
        );

        chronographRegister = [];
        departureButtonRegister = [];
        testee.showChronographWarning.listen(chronographRegister.add);
        testee.showDepartureProcessButton.listen(departureButtonRegister.add);
        processStreams(fakeAsync: fakeAsync);
      });
    }

    setUp(() {
      mockJourneyViewModel = MockJourneyViewModel();
      mockJourneyPositionViewModel = MockJourneyPositionViewModel();
      mockRuFeatureProvider = MockRuFeatureProvider();

      journeySubject = BehaviorSubject<Journey?>.seeded(null);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());

      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
      when(mockJourneyPositionViewModel.model).thenAnswer((_) => journeyPositionSubject.stream);
      when(
        mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
      ).thenAnswer((_) => Future.value(true));

      setupTestee();
    });

    tearDown(() {
      testee.dispose();
      journeySubject.close();
      journeyPositionSubject.close();
    });

    test('showChronographWarning_whenCreated_emitsTrue', () {
      expect(chronographRegister, orderedEquals([true]));
    });

    test('showDepartureProcessButton_whenCreated_emitsFalse', () {
      expect(departureButtonRegister, orderedEquals([false]));
    });

    group('showDepartureProcessButton – position eligibility', () {
      test('whenPositionIsNull_emitsFalse', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: null));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister.last, isFalse);
      });

      test('whenPositionIsServicePoint_emitsTrue', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister.last, isTrue);
      });

      test('whenPositionChangesFromNullToServicePoint_emitsFalseThenTrue', () {
        expect(departureButtonRegister, orderedEquals([false]));

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister, orderedEquals([false, true]));
      });

      test('whenPositionIsIntermediateSignal_emitsTrue', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: intermediateSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister.last, isTrue);
      });

      test('whenPositionIsExitSignal_emitsFalse', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: exitSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister.last, isFalse);
      });

      test('whenPositionChangesFromServicePointToEntrySignal_emitsTrue_thenFalse', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);
        departureButtonRegister.clear();

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: entrySignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister, orderedEquals([false]));
      });

      test('whenMultipleIneligiblePositionUpdates_distinctSuppressesDuplicateFalse', () {
        final initialLength = departureButtonRegister.length;

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: entrySignal));
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: exitSignal));
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: blockSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister.length, initialLength);
      });
    });

    group('toggleChronographWarning', () {
      test('whenFeatureEnabled_togglesFromTrueToFalse', () {
        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        expect(chronographRegister.last, isFalse);
      });

      test('whenFeatureEnabled_togglesBackToTrueOnSecondCall', () {
        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);
        chronographRegister.clear();

        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        expect(chronographRegister.last, isTrue);
      });

      test('whenFeatureDisabled_doesNotChangeChronographWarning', () {
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(false));

        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        // distinct() suppresses second true; the register must still be [true]
        expect(chronographRegister, orderedEquals([true]));
      });

      test('whenFeatureDisabled_emitsNoAdditionalValue', () {
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(false));
        chronographRegister.clear();

        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        expect(chronographRegister, isEmpty);
      });
    });

    group('journeyIdentificationChanged – new train identification', () {
      test('whenTrainIdentificationChanges_showChronographWarningEmitsTrue', () {
        final trainId1 = TrainIdentification(
          ru: RailwayUndertaking.sbbP,
          trainNumber: '1234',
          date: DateTime(2026, 3, 24),
        );
        final trainId2 = TrainIdentification(
          ru: RailwayUndertaking.sbbP,
          trainNumber: '5678',
          date: DateTime(2026, 3, 24),
        );

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId1),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);
        expect(chronographRegister.last, isTrue);

        testAsync.run((_) => testee.toggleChronographWarning());
        testAsync.elapse(Duration.zero);
        expect(chronographRegister.last, isFalse);
        chronographRegister.clear();

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId2),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        expect(chronographRegister, contains(isTrue));
      });

      test('whenTrainIdentificationChanges_showDepartureProcessButtonEmitsFalse', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);
        expect(departureButtonRegister.last, isTrue);
        departureButtonRegister.clear();

        final trainId1 = TrainIdentification(
          ru: RailwayUndertaking.sbbP,
          trainNumber: '1111',
          date: DateTime(2026, 3, 24),
        );
        final trainId2 = TrainIdentification(
          ru: RailwayUndertaking.sbbP,
          trainNumber: '2222',
          date: DateTime(2026, 3, 24),
        );

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId1),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId2),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        expect(departureButtonRegister, contains(isFalse));
      });

      test('whenTrainIdentificationUnchanged_chronographWarningStatePreserved', () {
        final trainId = TrainIdentification(
          ru: RailwayUndertaking.sbbP,
          trainNumber: '9999',
          date: DateTime(2026, 3, 24),
        );

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        testAsync.run((_) => testee.toggleChronographWarning());
        testAsync.elapse(Duration.zero);
        expect(chronographRegister.last, isFalse);
        chronographRegister.clear();

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(trainIdentification: trainId),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        expect(chronographRegister.where((v) => v == true), isEmpty);
      });

      test('whenJourneyChangesFromNullToFirstJourney_chronographWarningEmitsTrue', () {
        // Toggle to false first so the reset to true is observable via distinct()
        testAsync.run((_) => testee.toggleChronographWarning());
        testAsync.elapse(Duration.zero);
        expect(chronographRegister.last, isFalse);
        chronographRegister.clear();

        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(
                trainIdentification: TrainIdentification(
                  ru: RailwayUndertaking.sbbP,
                  trainNumber: '42',
                  date: DateTime(2026, 3, 24),
                ),
              ),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);

        expect(chronographRegister, contains(isTrue));
      });
    });

    test('whenPositionIsServicePointAndChronographToggled_bothStreamsEmitCorrectly', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
      });
      processStreams(fakeAsync: testAsync);
      expect(departureButtonRegister.last, isTrue);

      testAsync.run((_) {
        testee.toggleChronographWarning();
      });
      testAsync.elapse(Duration.zero);

      expect(chronographRegister.last, isFalse);
      expect(departureButtonRegister.last, isTrue);
    });

    test('whenJourneyUpdatedWithSameId_departureButtonStatePreserved', () {
      final trainId = TrainIdentification(
        ru: RailwayUndertaking.sbbP,
        trainNumber: '777',
        date: DateTime(2026, 3, 24),
      );

      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        journeySubject.add(
          Journey(
            metadata: Metadata(trainIdentification: trainId),
            data: [],
          ),
        );
      });
      processStreams(fakeAsync: testAsync);
      departureButtonRegister.clear();

      testAsync.run((_) {
        journeySubject.add(
          Journey(
            metadata: Metadata(trainIdentification: trainId),
            data: [],
          ),
        );
      });
      processStreams(fakeAsync: testAsync);

      expect(departureButtonRegister.where((v) => v == false), isEmpty);
    });
  });
}
