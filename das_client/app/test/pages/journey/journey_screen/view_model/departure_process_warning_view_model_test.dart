import 'package:app/pages/journey/journey_screen/view_model/departure_process_warning_view_model.dart';
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
import 'departure_process_warning_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<RuFeatureProvider>(),
])
void main() {
  group('DepartureProcessWarningViewModel', () {
    late DepartureProcessWarningViewModel testee;
    late MockJourneyViewModel mockJourneyViewModel;
    late MockRuFeatureProvider mockRuFeatureProvider;

    late BehaviorSubject<Journey?> journeySubject;

    late List<bool> chronographRegister;
    late FakeAsync testAsync;

    void setupTestee() {
      fakeAsync((fakeAsync) {
        testAsync = fakeAsync;

        testee = DepartureProcessWarningViewModel(
          ruFeatureProvider: mockRuFeatureProvider,
          journeyViewModel: mockJourneyViewModel,
        );

        chronographRegister = [];
        testee.showChronographWarning.listen(chronographRegister.add);
        processStreams(fakeAsync: fakeAsync);
      });
    }

    setUp(() {
      mockJourneyViewModel = MockJourneyViewModel();
      mockRuFeatureProvider = MockRuFeatureProvider();

      journeySubject = BehaviorSubject<Journey?>.seeded(null);

      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
      when(
        mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
      ).thenAnswer((_) => Future.value(true));

      setupTestee();
    });

    tearDown(() {
      testee.dispose();
      journeySubject.close();
    });

    test('showChronographWarning_whenCreated_emitsTrue', () {
      expect(chronographRegister, orderedEquals([true]));
    });

    group('toggleChronographWarning', () {
      // Pushes a journey so that journeyIdentificationChanged fires and
      // _isDepartureProcessFeatureEnabled is set to true.
      void activateFeature() {
        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(
                trainIdentification: TrainIdentification(
                  ru: RailwayUndertaking.sbbP,
                  trainNumber: '1',
                  date: DateTime(2026, 3, 24),
                ),
              ),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);
        chronographRegister.clear();
      }

      test('whenFeatureEnabled_togglesFromTrueToFalse', () {
        activateFeature();

        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        expect(chronographRegister.last, isFalse);
      });

      test('whenFeatureEnabled_togglesBackToTrueOnSecondCall', () {
        activateFeature();

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
        // Disable the feature and push a new identification so that
        // journeyIdentificationChanged fires with enabled=false.
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(false));
        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(
                trainIdentification: TrainIdentification(
                  ru: RailwayUndertaking.sbbP,
                  trainNumber: '1',
                  date: DateTime(2026, 3, 24),
                ),
              ),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);
        // After journeyIdentificationChanged with disabled feature the warning
        // is seeded false; distinct() suppresses equal values.
        chronographRegister.clear();

        testAsync.run((_) {
          testee.toggleChronographWarning();
        });
        testAsync.elapse(Duration.zero);

        // Toggle must be ignored when feature is disabled – no new emission.
        expect(chronographRegister, isEmpty);
      });

      test('whenFeatureDisabled_emitsNoAdditionalValue', () {
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(false));
        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(
                trainIdentification: TrainIdentification(
                  ru: RailwayUndertaking.sbbP,
                  trainNumber: '1',
                  date: DateTime(2026, 3, 24),
                ),
              ),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);
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

        // Push the same identification multiple times – journeyUpdated fires,
        // not journeyIdentificationChanged, so the warning must stay false.
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
        // Toggle to false first so the reset to true is observable via distinct().
        // At this point no journey has arrived yet, so the feature is disabled
        // and the toggle is a no-op; force false by adding a disabled-feature
        // journey first, then re-enable and push a new identification.
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(false));
        testAsync.run((_) {
          journeySubject.add(
            Journey(
              metadata: Metadata(
                trainIdentification: TrainIdentification(
                  ru: RailwayUndertaking.sbbP,
                  trainNumber: '0',
                  date: DateTime(2026, 3, 24),
                ),
              ),
              data: [],
            ),
          );
        });
        processStreams(fakeAsync: testAsync);
        // Warning is now false (feature disabled).
        chronographRegister.clear();

        // Re-enable the feature and change the identification.
        when(
          mockRuFeatureProvider.isRuFeatureEnabled(RuFeatureKeys.departureProcess),
        ).thenAnswer((_) => Future.value(true));
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
  });
}
