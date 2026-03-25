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
  });
}
