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

import 'journey_validation_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  final sbbP = TrainIdentification(companyCode: '1285', trainNumber: 'T12', date: DateTime.now());
  final blsC = TrainIdentification(companyCode: '1385', trainNumber: 'T12', date: DateTime.now());
  const a200 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 200);
  const a100 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 100);
  const n100 = BrakeSeries(trainSeries: .N, brakedWeightPercentage: 100);
  const n90 = BrakeSeries(trainSeries: .N, brakedWeightPercentage: 90);
  const d100 = BrakeSeries(trainSeries: .D, brakedWeightPercentage: 100);
  const d200 = BrakeSeries(trainSeries: .D, brakedWeightPercentage: 200);
  const r100 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 100);
  const r50 = BrakeSeries(trainSeries: .R, brakedWeightPercentage: 50);
  final availableBrakeSeries = {a100, a200, n100, n90, d100, d200, r100, r50};

  late JourneyValidationViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late FakeAsync testAsync;
  final List<MultiBrakeSeriesSelectionModel> brakeSeriesRegister = [];
  final List<MultiBrakeSeriesSelectionModel> editingBrakeSeriesRegister = [];

  setUp(() {
    testAsync = FakeAsync().run((testAsync) {
      mockJourneyViewModel = MockJourneyViewModel();
      journeySubject = BehaviorSubject<Journey?>();
      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);

      testee = JourneyValidationViewModel(journeyViewModel: mockJourneyViewModel);
      testee.brakeSeriesModel.listen(brakeSeriesRegister.add);
      testee.editingBrakeSeriesModel.listen(editingBrakeSeriesRegister.add);
      return testAsync;
    });
    testAsync.flushMicrotasks();
    brakeSeriesRegister.clear();
    editingBrakeSeriesRegister.clear();
  });

  tearDown(() {
    brakeSeriesRegister.clear();
    editingBrakeSeriesRegister.clear();
    journeySubject.close();
    testee.dispose();
  });

  group('Journey is null', () {
    test('initialState_whenNoJourney_thenNoBrakeSeries', () {
      expect(testee.brakeSeriesModelValue, equals(MultiBrakeSeriesSelectionModel()));
      expect(testee.editingBrakeSeriesModelValue, equals(MultiBrakeSeriesSelectionModel()));
      expect(brakeSeriesRegister, isEmpty);
      expect(editingBrakeSeriesRegister, isEmpty);
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
    expect(testee.editingBrakeSeriesModelValue, equals(MultiBrakeSeriesSelectionModel()));
    // swallowed by distinct
    expect(brakeSeriesRegister, isEmpty);
    expect(editingBrakeSeriesRegister, isEmpty);
  });

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

    final expectedModel = MultiBrakeSeriesSelectionModel(
      selectedBrakeSeries: [a100],
      allowedBrakeSeries: {a200, a100, d200, d100},
      availableBrakeSeries: availableBrakeSeries,
    );
    expect(brakeSeriesRegister.first, equals(expectedModel));
    expect(brakeSeriesRegister, hasLength(1));
    // onJourneyChanged resets both the saved and editing selection
    expect(editingBrakeSeriesRegister.first, equals(expectedModel));
    expect(editingBrakeSeriesRegister, hasLength(1));
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
      brakeSeriesRegister.clear();
      editingBrakeSeriesRegister.clear();
    });

    test('initialState_whenNoBrakeSeriesSelected_thenAllAllowed', () {
      // EXPECT
      final expectedModel = MultiBrakeSeriesSelectionModel(
        selectedBrakeSeries: [],
        allowedBrakeSeries: {a100, a200, n100, n90, d100, d200, r100, r50},
        availableBrakeSeries: availableBrakeSeries,
      );
      expect(testee.brakeSeriesModelValue, equals(expectedModel));
      expect(testee.editingBrakeSeriesModelValue, equals(expectedModel));
      expect(brakeSeriesRegister, isEmpty);
      expect(editingBrakeSeriesRegister, isEmpty);
    });

    test('toggleBrakeSeriesSelection_whenToggled_thenOnlyEditingModelChangesWithCorrectTrainSeries', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(d100);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        editingBrakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [d100],
            allowedBrakeSeries: {a100, a200, d100, d200},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, hasLength(1));
      // the saved model is untouched until saveBrakeSeriesSelection is called
      expect(
        testee.brakeSeriesModelValue,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(brakeSeriesRegister, isEmpty);
    });

    test('toggleBrakeSeriesSelection_whenRBrakeSeriesToggled_thenOnlyRAllowed', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(r50);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        editingBrakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [r50],
            allowedBrakeSeries: {r50, r100},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, hasLength(1));
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
        editingBrakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, hasLength(2));
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
        editingBrakeSeriesRegister.last,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [a100, d200, d100],
            allowedBrakeSeries: {a100, a200, d100, d200},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, hasLength(3));
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
        testee.editingBrakeSeriesModelValue,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, isEmpty);
    });

    test('toggleBrakeSeriesSelection_whenInvalidCombination_thenRejectsSilently', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(a100);
        testAsync.flushMicrotasks();
        editingBrakeSeriesRegister.clear();
        testee.toggleBrakeSeriesSelection(r50);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        testee.editingBrakeSeriesModelValue,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [a100],
            allowedBrakeSeries: {a200, a100, d200, d100},
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
      expect(editingBrakeSeriesRegister, isEmpty);
    });

    test('startBrakeSeriesEditing_whenCalled_thenResetsEditingModelToSaved', () {
      // ARRANGE
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(d100);
      });
      testAsync.flushMicrotasks();

      // ACT
      testAsync.run((_) {
        testee.startBrakeSeriesEditing();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(
        testee.editingBrakeSeriesModelValue,
        equals(
          MultiBrakeSeriesSelectionModel(
            selectedBrakeSeries: [],
            allowedBrakeSeries: availableBrakeSeries,
            availableBrakeSeries: availableBrakeSeries,
          ),
        ),
      );
    });

    test('saveBrakeSeriesSelection_whenCalled_thenSavedModelMatchesEditingModel', () {
      // ARRANGE
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(d100);
      });
      testAsync.flushMicrotasks();

      // ACT
      testAsync.run((_) {
        testee.saveBrakeSeriesSelection();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      final expectedModel = MultiBrakeSeriesSelectionModel(
        selectedBrakeSeries: [d100],
        allowedBrakeSeries: {a100, a200, d100, d200},
        availableBrakeSeries: availableBrakeSeries,
      );
      expect(testee.brakeSeriesModelValue, equals(expectedModel));
      expect(brakeSeriesRegister.last, equals(expectedModel));
      expect(brakeSeriesRegister, hasLength(1));
    });

    test('toggleBrakeSeriesSelection_whenNotSaved_thenDiscardedByStartBrakeSeriesEditing', () {
      testAsync.run((_) {
        testee.startBrakeSeriesEditing();
        testee.toggleBrakeSeriesSelection(d100);
      });
      testAsync.flushMicrotasks();
      expect(testee.editingBrakeSeriesModelValue.selectedBrakeSeries, equals([d100]));
      expect(testee.brakeSeriesModelValue.selectedBrakeSeries, isEmpty);

      testAsync.run((_) {
        testee.startBrakeSeriesEditing();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(testee.editingBrakeSeriesModelValue.selectedBrakeSeries, isEmpty);
      expect(testee.brakeSeriesModelValue.selectedBrakeSeries, isEmpty);
    });
  });

  group('journey has more than ten combinable brake series', () {
    const a300 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 300);
    const a400 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 400);
    const a500 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 500);
    const a600 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 600);
    const a700 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 700);
    const a800 = BrakeSeries(trainSeries: .A, brakedWeightPercentage: 800);
    const d300 = BrakeSeries(trainSeries: .D, brakedWeightPercentage: 300);
    final manyBrakeSeries = {a100, a200, a300, a400, a500, a600, a700, a800, d100, d200, d300};

    setUp(() {
      testAsync.run(
        (_) => journeySubject.add(
          Journey(
            metadata: Metadata(
              trainIdentification: sbbP,
              availableBrakeSeries: manyBrakeSeries,
            ),
            data: [],
          ),
        ),
      );
      testAsync.flushMicrotasks();
      brakeSeriesRegister.clear();
      editingBrakeSeriesRegister.clear();
    });

    test('toggleBrakeSeriesSelection_whenTenSelected_thenAllTenAreSelected', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(a100);
        testee.toggleBrakeSeriesSelection(a200);
        testee.toggleBrakeSeriesSelection(a300);
        testee.toggleBrakeSeriesSelection(a400);
        testee.toggleBrakeSeriesSelection(a500);
        testee.toggleBrakeSeriesSelection(a600);
        testee.toggleBrakeSeriesSelection(a700);
        testee.toggleBrakeSeriesSelection(a800);
        testee.toggleBrakeSeriesSelection(d100);
        testee.toggleBrakeSeriesSelection(d200);
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(testee.editingBrakeSeriesModelValue.selectedBrakeSeries, hasLength(10));
      expect(editingBrakeSeriesRegister, hasLength(10));
    });

    test('toggleBrakeSeriesSelection_whenTenSelected_thenNoOtherAvailable', () {
      // ACT
      testAsync.run((_) {
        testee.toggleBrakeSeriesSelection(a100);
        testee.toggleBrakeSeriesSelection(a200);
        testee.toggleBrakeSeriesSelection(a300);
        testee.toggleBrakeSeriesSelection(a400);
        testee.toggleBrakeSeriesSelection(a500);
        testee.toggleBrakeSeriesSelection(a600);
        testee.toggleBrakeSeriesSelection(a700);
        testee.toggleBrakeSeriesSelection(a800);
        testee.toggleBrakeSeriesSelection(d100);
        testee.toggleBrakeSeriesSelection(d200);
        testAsync.flushMicrotasks();
        editingBrakeSeriesRegister.clear();
      });
      testAsync.flushMicrotasks();

      // EXPECT
      expect(testee.editingBrakeSeriesModelValue.allowedBrakeSeries, {
        a100,
        a200,
        a300,
        a400,
        a500,
        a600,
        a700,
        a800,
        d100,
        d200,
      });
      expect(editingBrakeSeriesRegister, isEmpty);
    });
  });
}
