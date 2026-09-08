import 'package:app/pages/journey/journey_validation/journey_validation_view_model.dart';
import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'validation_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  final sbbP = TrainIdentification(companyCode: '1285', trainNumber: 'T12', date: DateTime.now());
  final blsC = TrainIdentification(companyCode: '1385', trainNumber: 'T12', date: DateTime.now());

  late JourneyValidationViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late FakeAsync testAsync;
  final List<bool> validationModeRegister = [];
  final List<MultiBrakeSeriesSelectionModel> brakeSeriesRegister = [];

  setUp(() {
    testAsync = FakeAsync().run((testAsync) {
      mockJourneyViewModel = MockJourneyViewModel();
      journeySubject = BehaviorSubject<Journey?>();
      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);

      testee = JourneyValidationViewModel(journeyViewModel: mockJourneyViewModel);
      testee.validationMode.listen(validationModeRegister.add);
      testee.brakeSeriesModel.listen(brakeSeriesRegister.add);
      return testAsync;
    });
    testAsync.flushMicrotasks();
  });

  tearDown(() {
    validationModeRegister.clear();
    brakeSeriesRegister.clear();
    journeySubject.close();
    testee.dispose();
  });

  group('Journey is null', () {
    test('initialState_whenValidationModeNeverToggled_thenIsFalse', () {
      expect(testee.validationModeValue, isFalse);
      expect(validationModeRegister, hasLength(1));
    });

    test('toggleValidationMode_whenModeToggled_thenIsTrue', () {
      // ACT
      testAsync.run((_) {
        testee.toggleValidationMode();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(testee.validationModeValue, isTrue);
      expect(validationModeRegister, hasLength(2));
    });

    test('toggleValidationMode_whenModeToggledTwice_thenIsFalse', () {
      // ACT
      testAsync.run((_) {
        testee.toggleValidationMode();
        testee.toggleValidationMode();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(testee.validationModeValue, isFalse);
      expect(validationModeRegister, hasLength(3));
    });

    test('initialState_whenNoJourney_thenNoBrakeSeries', () {
      expect(testee.brakeSeriesModelValue, equals(MultiBrakeSeriesSelectionModel()));
      expect(brakeSeriesRegister.first, equals(MultiBrakeSeriesSelectionModel()));
      expect(brakeSeriesRegister, hasLength(1));
    });
  });

  test('initialState_whenJourneyWithoutBrakeSeriesData_thenHasNoBrakeSeriesData', () {
    // ACT
    testAsync.run(
      (_) => journeySubject.add(
        Journey(
          metadata: Metadata(trainIdentification: sbbP),
          data: [],
        ),
      ),
    );
    testAsync.flushMicrotasks();

    // EXPECT
    expect(testee.brakeSeriesModelValue, equals(MultiBrakeSeriesSelectionModel()));
    expect(brakeSeriesRegister.first, equals(MultiBrakeSeriesSelectionModel()));
    // swallowed by distinct
    expect(brakeSeriesRegister, hasLength(1));
  });

  test('initialState_whenJourneyWithSingleBrakeSeriesData_thenHasCorrectBrakeSeriesData', () {
    // ACT
    const brakeSeriesA = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 100);
    testAsync.run(
      (_) => journeySubject.add(
        Journey(
          metadata: Metadata(
            trainIdentification: sbbP,
            brakeSeries: brakeSeriesA,
            availableBrakeSeries: {brakeSeriesA},
          ),
          data: [],
        ),
      ),
    );
    testAsync.flushMicrotasks();

    // EXPECT
    expect(
      testee.brakeSeriesModelValue,
      equals(
        MultiBrakeSeriesSelectionModel(
          selectedBrakeSeries: [brakeSeriesA],
          allowedBrakeSeries: {brakeSeriesA},
          availableBrakeSeries: {brakeSeriesA},
        ),
      ),
    );
    expect(
      brakeSeriesRegister.last,
      equals(
        MultiBrakeSeriesSelectionModel(
          selectedBrakeSeries: [brakeSeriesA],
          allowedBrakeSeries: {brakeSeriesA},
          availableBrakeSeries: {brakeSeriesA},
        ),
      ),
    );
    expect(brakeSeriesRegister, hasLength(2));
  });

  const a200 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 200);
  const a100 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 100);
  const n100 = BrakeSeries(trainSeries: .N, brakedWeightPercentage: 100);
  const n90 = BrakeSeries(trainSeries: .N, brakedWeightPercentage: 90);
  const d100 = BrakeSeries(trainSeries: .D, brakedWeightPercentage: 100);
  const d200 = BrakeSeries(trainSeries: .D, brakedWeightPercentage: 200);
  const r100 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 100);
  const r50 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 50);
  final availableBrakeSeries = {a100, a200, n100, n90, d100, d200, r100, r50};

  test('initialState_whenBrakeSeriesASelected_thenOnlyAllowedAOrD', () {
    testAsync.run(
      (_) => journeySubject.add(
        Journey(
          metadata: Metadata(
            trainIdentification: sbbP,
            brakeSeries: a100,
            availableBrakeSeries: availableBrakeSeries,
          ),
          data: [],
        ),
      ),
    );
    testAsync.flushMicrotasks();

    expect(
      brakeSeriesRegister.last,
      equals(
        MultiBrakeSeriesSelectionModel(
          selectedBrakeSeries: [a100],
          allowedBrakeSeries: {a200, a100, d200, d100},
          availableBrakeSeries: availableBrakeSeries,
        ),
      ),
    );
    expect(brakeSeriesRegister, hasLength(2));
  });

  group('journey has multiple brake series', () {
    setUp(() {
      testAsync.run(
        (_) => journeySubject.add(
          Journey(
            metadata: Metadata(
              trainIdentification: sbbP,
              availableBrakeSeries: availableBrakeSeries,
            ),
            data: [],
          ),
        ),
      );
      testAsync.flushMicrotasks();
    });

    test('initialState_whenNoBrakeSeriesSelected_thenAllAllowed', () {
      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: {a100, a200, n100, n90, d100, d200, r100, r50},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(2));
    });

    test('toggleSelectedBrakeSeries_whenDBrakeSeriesSelected_thenAOrDAllowed', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(d100);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [d100],
            allowedBrakeSeries: {a100, a200, d100, d200},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(3));
    });

    test('toggleBrakeSeriesSelection_whenRBrakeSeriesSelected_thenOnlyRAllowed', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(r50);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [r50],
            allowedBrakeSeries: {r50, r100},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(3));
    });

    test('toggleBrakeSeriesSelection_whenSelectedThenDeselected_thenEmitsCorrectly', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(r50);
        testee.toggleBrakeSeriesSelection(r50);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(4));
    });

    test('toggleBrakeSeriesSelection_whenMultipleSelected_thenEmitsInCorrectOrder', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(d100);
        testee.toggleBrakeSeriesSelection(a100);
        testee.toggleBrakeSeriesSelection(d200);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [a100, d200, d100],
            allowedBrakeSeries: {a100, a200, d100, d200},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(5));
    });

    test('toggleBrakeSeriesSelection_whenNonAvailableBrakeSeries_thenRejectsSilently', () {
      final r40 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 40);
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(r40);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(2));
    });

    test('toggleBrakeSeriesSelection_whenInvalidCombination_thenRejectsSilently', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(a100);
        testee.toggleBrakeSeriesSelection(r50);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        brakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [a100],
            allowedBrakeSeries: {a200, a100, d200, d100},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, hasLength(3));
    });
  });
}
