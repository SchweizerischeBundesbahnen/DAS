import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/checklist_departure_process_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'checklist_departure_process_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<RuFeatureProvider>(),
  MockSpec<UxTestingViewModel>(),
])
void main() {
  group('ChecklistDepartureProcessViewModel', () {
    late ChecklistDepartureProcessViewModel testee;
    late MockJourneyViewModel mockJourneyViewModel;
    late MockJourneyPositionViewModel mockJourneyPositionViewModel;
    late MockRuFeatureProvider mockRuFeatureProvider;
    late MockUxTestingViewModel mockUxTestingViewModel;

    late BehaviorSubject<Journey?> journeySubject;
    late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
    late BehaviorSubject<KoaState> koaStateSubject;

    late List<ChecklistDepartureProcessModel> modelRegister;
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
          uxTestingViewModel: mockUxTestingViewModel,
          journeyViewModel: mockJourneyViewModel,
        );

        modelRegister = [];
        testee.model.listen(modelRegister.add);
        processStreams(fakeAsync: fakeAsync);
      });
    }

    setUp(() {
      mockJourneyViewModel = MockJourneyViewModel();
      mockJourneyPositionViewModel = MockJourneyPositionViewModel();
      mockRuFeatureProvider = MockRuFeatureProvider();
      mockUxTestingViewModel = MockUxTestingViewModel();

      journeySubject = BehaviorSubject<Journey?>.seeded(null);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      koaStateSubject = BehaviorSubject<KoaState>.seeded(KoaState.waitHide);

      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
      when(mockJourneyPositionViewModel.model).thenAnswer((_) => journeyPositionSubject.stream);
      when(mockRuFeatureProvider.isRuFeatureEnabled(.departureProcess)).thenAnswer((_) => Future.value(true));
      when(mockUxTestingViewModel.koaState).thenAnswer((_) => koaStateSubject.stream);

      setupTestee();
    });

    tearDown(() {
      testee.dispose();
      journeySubject.close();
      journeyPositionSubject.close();
      koaStateSubject.close();
    });

    test('model_whenCreated_emitsDisabled', () {
      expect(modelRegister, orderedEquals([isA<ChecklistDepartureProcessDisabled>()]));
    });

    group('model – position eligibility', () {
      test('whenPositionIsNull_emitsDisabled', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: null));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister.last, isA<ChecklistDepartureProcessDisabled>());
      });

      test('whenPositionIsServicePoint_emitsNoCustomerOrientedDeparture', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
      });

      test('whenPositionChangesFromNullToServicePoint_emitsDisabledThenNoCustomerOrientedDeparture', () {
        expect(modelRegister, orderedEquals([isA<ChecklistDepartureProcessDisabled>()]));

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);

        expect(
          modelRegister,
          orderedEquals([
            isA<ChecklistDepartureProcessDisabled>(),
            isA<NoCustomerOrientedDepartureChecklist>(),
          ]),
        );
      });

      test('whenPositionIsIntermediateSignal_emitsNoCustomerOrientedDeparture', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: intermediateSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
      });

      test('whenPositionIsExitSignal_emitsDisabled', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: exitSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister.last, isA<ChecklistDepartureProcessDisabled>());
      });

      test('whenPositionChangesFromServicePointToEntrySignal_emitsNoCustomerOrientedDeparture_thenDisabled', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);
        modelRegister.clear();

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: entrySignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister, orderedEquals([isA<ChecklistDepartureProcessDisabled>()]));
      });

      test('whenMultipleIneligiblePositionUpdates_distinctSuppressesDuplicateDisabled', () {
        final initialLength = modelRegister.length;

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: entrySignal));
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: exitSignal));
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: blockSignal));
        });
        processStreams(fakeAsync: testAsync);

        expect(modelRegister.length, initialLength);
      });
    });

    test('whenKoaStateIsWait_emitsCustomerOrientedDeparture', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
      });
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();

      testAsync.run((_) {
        koaStateSubject.add(KoaState.wait);
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<CustomerOrientedDepartureChecklist>());
      expect((modelRegister.last as CustomerOrientedDepartureChecklist).koaState, KoaState.wait);
    });

    test('whenKoaStateIsWaitCancelled_emitsCustomerOrientedDeparture', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
      });
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();

      testAsync.run((_) {
        koaStateSubject.add(KoaState.waitCancelled);
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<CustomerOrientedDepartureChecklist>());
      expect((modelRegister.last as CustomerOrientedDepartureChecklist).koaState, KoaState.waitCancelled);
    });

    test('whenKoaStateIsWaitHide_emitsNoCustomerOrientedDeparture', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        koaStateSubject.add(KoaState.waitHide);
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
    });

    test('whenKoaStateChangesFromWaitToWaitHide_emitsCustomerOrientedDeparture_thenNoCustomerOrientedDeparture', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        koaStateSubject.add(KoaState.wait);
      });
      processStreams(fakeAsync: testAsync);
      modelRegister.clear();

      testAsync.run((_) {
        koaStateSubject.add(KoaState.waitHide);
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
    });

    group('nextStop – passed through in model', () {
      test('whenPositionHasNextStop_modelContainsNextStop', () {
        final nextStop = ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 1, kilometre: []);

        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA, nextStop: nextStop));
        });
        processStreams(fakeAsync: testAsync);

        final last = modelRegister.last;
        expect(last, isA<NoCustomerOrientedDepartureChecklist>());
        expect((last as NoCustomerOrientedDepartureChecklist).nextStop, nextStop);
      });
    });

    group('journeyIdentificationChanged – new train identification', () {
      test('whenTrainIdentificationChanges_modelEmitsDisabled', () {
        testAsync.run((_) {
          journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
        });
        processStreams(fakeAsync: testAsync);
        expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
        modelRegister.clear();

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

        expect(modelRegister, contains(isA<ChecklistDepartureProcessDisabled>()));
      });
    });

    test('whenFeatureDisabled_onCreation_emitsDisabled', () {
      when(mockRuFeatureProvider.isRuFeatureEnabled(.departureProcess)).thenAnswer((_) => Future.value(false));

      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: null));
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<ChecklistDepartureProcessDisabled>());
    });

    test('whenFeatureDisabled_andPositionIsServicePoint_emitsDisabled', () {
      when(mockRuFeatureProvider.isRuFeatureEnabled(.departureProcess)).thenAnswer((_) => Future.value(false));

      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<ChecklistDepartureProcessDisabled>());
    });

    test('whenFeatureDisabled_andPositionIsIntermediateSignal_emitsDisabled', () {
      when(mockRuFeatureProvider.isRuFeatureEnabled(.departureProcess)).thenAnswer((_) => Future.value(false));

      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: intermediateSignal));
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.last, isA<ChecklistDepartureProcessDisabled>());
    });

    test('whenFeatureDisabledAfterEligiblePosition_emitsDisabled', () {
      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: servicePointA));
      });
      processStreams(fakeAsync: testAsync);
      expect(modelRegister.last, isA<NoCustomerOrientedDepartureChecklist>());
      modelRegister.clear();

      when(mockRuFeatureProvider.isRuFeatureEnabled(.departureProcess)).thenAnswer((_) => Future.value(false));

      testAsync.run((_) {
        journeyPositionSubject.add(JourneyPositionModel(currentPosition: intermediateSignal));
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister, orderedEquals([isA<ChecklistDepartureProcessDisabled>()]));
    });

    test('whenJourneyUpdatedWithSameId_modelStatePreserved', () {
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
      modelRegister.clear();

      testAsync.run((_) {
        journeySubject.add(
          Journey(
            metadata: Metadata(trainIdentification: trainId),
            data: [],
          ),
        );
      });
      processStreams(fakeAsync: testAsync);

      expect(modelRegister.whereType<ChecklistDepartureProcessDisabled>(), isEmpty);
    });
  });
}
