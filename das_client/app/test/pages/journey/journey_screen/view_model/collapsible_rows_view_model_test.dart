import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'collapsible_rows_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>()])
void main() {
  late CollapsibleRowsViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
  late BehaviorSubject<FormationRunChange?> formationRunSubject;

  final footNote = FootNote(text: 'Test footnote', identifier: 'FN1');
  final footNoteData = OpFootNote(order: 10, footNote: footNote);
  final footNote2 = FootNote(text: 'Second footnote', identifier: 'FN2');
  final footNoteData2 = OpFootNote(order: 20, footNote: footNote2);

  // SIM footnote: type == contact, refText == 'SIM'
  final simFootNote = FootNote(text: 'SIM note', identifier: 'SIM1', type: FootNoteType.contact, refText: 'SIM');
  final simFootNoteData = OpFootNote(order: 8, footNote: simFootNote);

  final indicator = UncodedOperationalIndication(order: 15, texts: ['Some indication']);
  final indicator2 = UncodedOperationalIndication(order: 25, texts: ['Another indication']);

  // JourneyPoints used as position markers (currentPosition/lastPosition must be JourneyPoint)
  final signal1 = Signal(order: 5, kilometre: []);
  final signalBetween1And2 = Signal(order: 12, kilometre: []); // between footNoteData(10) and indicator(15)
  final signalBetween2And3 = Signal(order: 17, kilometre: []); // between indicator(15) and footNoteData2(20)
  final signalBetween3And4 = Signal(order: 22, kilometre: []); // between footNoteData2(20) and indicator2(25)
  final signal2 = Signal(order: 30, kilometre: []);

  // journey: signal1(5), simFootNoteData(8), footNoteData(10), signalBetween1And2(12), indicator(15),
  //          signalBetween2And3(17), footNoteData2(20), signalBetween3And4(22), indicator2(25), signal2(30)
  final baseJourney = Journey(
    metadata: Metadata(),
    data: [
      signal1,
      simFootNoteData,
      footNoteData,
      signalBetween1And2,
      indicator,
      signalBetween2And3,
      footNoteData2,
      signalBetween3And4,
      indicator2,
      signal2,
    ],
  );

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    journeySubject = BehaviorSubject<Journey?>.seeded(baseJourney);
    when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);

    journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
    formationRunSubject = BehaviorSubject<FormationRunChange?>.seeded(null);

    testee = CollapsibleRowsViewModel(
      journeyPositionStream: journeyPositionSubject.stream,
      formationRunStream: formationRunSubject.stream,
      journeyViewModel: mockJourneyViewModel,
    );
  });

  tearDown(() {
    testee.dispose();
    journeySubject.close();
    journeyPositionSubject.close();
    formationRunSubject.close();
  });

  group('toggleRow', () {
    test('toggleRow_whenBaseFootNoteIsExpanded_thenCollapsesIt', () async {
      // ARRANGE
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);

      // ACT
      testee.toggleRow(footNoteData);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test('toggleRow_whenBaseFootNoteIsCollapsed_thenExpandsIt', () async {
      // ARRANGE
      testee.toggleRow(footNoteData);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);

      // ACT
      testee.toggleRow(footNoteData);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);
    });

    test('toggleRow_whenUncodedOperationalIndicationDefault_thenIsExpandedWithCollapsedContent', () async {
      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
    });

    test(
      'toggleRow_whenUncodedOperationalIndicationIsExpandedWithCollapsedContentAndContentExpandable_thenExpands',
      () async {
        // ARRANGE
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);

        // ACT
        testee.toggleRow(indicator, isContentExpandable: true);
        await processStreams();

        // EXPECT
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expanded);
      },
    );

    test(
      'toggleRow_whenUncodedOperationalIndicationIsExpandedWithCollapsedContentAndContentNotExpandable_thenCollapses',
      () async {
        // ARRANGE
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);

        // ACT
        testee.toggleRow(indicator, isContentExpandable: false);
        await processStreams();

        // EXPECT
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
      },
    );

    test('toggleRow_whenUncodedOperationalIndicationIsExpanded_thenCollapses', () async {
      // ARRANGE
      testee.toggleRow(indicator, isContentExpandable: true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expanded);

      // ACT
      testee.toggleRow(indicator, isContentExpandable: true);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
    });

    test('toggleRow_whenUncodedOperationalIndicationIsCollapsed_thenExpandsToExpandedWithCollapsedContent', () async {
      // ARRANGE
      testee.toggleRow(indicator);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);

      // ACT
      testee.toggleRow(indicator);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
    });

    test('toggleRow_whenTogglingOneRow_thenOtherRowsAreUnaffected', () async {
      // ARRANGE
      final initialStateIndicator = testee.collapsedRowsValue.stateOf(indicator);

      // ACT
      testee.toggleRow(footNoteData);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(indicator), initialStateIndicator);
    });

    test('toggleRow_whenToggled_thenEmitsNewStateOnStream', () async {
      // ARRANGE
      final emittedStates = <Map<int, CollapsedState>>[];
      final subscription = testee.collapsedRows.listen(emittedStates.add);
      await processStreams(); // flush the initial seeded value
      emittedStates.clear();

      // ACT
      testee.toggleRow(footNoteData);
      await processStreams();

      // EXPECT
      expect(emittedStates.length, 1);
      expect(emittedStates.first.stateOf(footNoteData), CollapsedState.collapsed);

      await subscription.cancel();
    });
  });

  group('collapsePassedAccordionRows', () {
    test('collapsePassedAccordionRows_whenPositionAdvancesPastFootNote_thenFootNoteIsCollapsed', () async {
      // ARRANGE - journey: signal1(5), footNoteData(10), indicator(15), footNoteData2(20), indicator2(25), signal2(30)

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2, // passed footNoteData(10)
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test(
      'collapsePassedAccordionRows_whenPositionAdvancesPastUncodedOperationalIndication_thenIndicatorIsCollapsed',
      () async {
        // ARRANGE

        // ACT
        journeyPositionSubject.add(
          JourneyPositionModel(
            lastPosition: signal1,
            currentPosition: signalBetween2And3, // passed footNoteData(10) and indicator(15)
          ),
        );
        await processStreams();

        // EXPECT
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
      },
    );

    test(
      'collapsePassedAccordionRows_whenPositionAdvancesOverMultipleCollapsibles_thenAllPassedAreCollapsed',
      () async {
        // ARRANGE

        // ACT
        journeyPositionSubject.add(
          JourneyPositionModel(
            lastPosition: signal1,
            currentPosition: signal2, // passed all collapsibles
          ),
        );
        await processStreams();

        // EXPECT
        expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(footNoteData2), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(indicator2), CollapsedState.collapsed);
      },
    );

    test('collapsePassedAccordionRows_whenCurrentSameAsLast_thenNothingChanges', () async {
      // ARRANGE
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signal1,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue, initialState);
    });

    test('collapsePassedAccordionRows_whenLastPositionIsNull_thenNothingChanges', () async {
      // ARRANGE
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: null,
          currentPosition: signal2,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue, initialState);
    });

    test('collapsePassedAccordionRows_whenCurrentPositionIsNull_thenNothingChanges', () async {
      // ARRANGE
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: null,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue, initialState);
    });

    test('collapsePassedAccordionRows_whenRowAlreadyCollapsed_thenRemainsCollapsed', () async {
      // ARRANGE
      testee.toggleRow(footNoteData);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test('collapsePassedAccordionRows_whenFutureCollapsiblesNotYetPassed_thenTheyAreNotCollapsed', () async {
      // ARRANGE

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2, // only footNoteData(10) is passed
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
      expect(testee.collapsedRowsValue.stateOf(footNoteData2), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(indicator2), CollapsedState.expandedWithCollapsedContent);
    });
  });

  group('journeyIdentificationChanged', () {
    test('journeyIdentificationChanged_whenJourneyChanges_thenCollapsedRowsAreReset', () async {
      // ARRANGE
      testee.toggleRow(footNoteData);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);

      // ACT
      final newTrainId = TrainIdentification(
        ru: RailwayUndertaking.sbbP,
        trainNumber: '999',
        date: DateTime(2026),
      );
      final newJourney = Journey(
        metadata: Metadata(trainIdentification: newTrainId),
        data: baseJourney.data,
      );
      journeySubject.add(newJourney);
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue, isEmpty);
    });
  });

  group('simTrain', () {
    test('simTrain_whenFormationRunIsSimTrain_thenSimFootNotesAreExpanded', () async {
      // ARRANGE - SIM footnotes start collapsed (no formation run)
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // ACT
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: true),
          previousFormationRun: null,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenFormationRunIsNotSimTrain_thenSimFootNotesAreCollapsed', () async {
      // ARRANGE - no SIM formation run

      // ACT
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: false),
          previousFormationRun: null,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenFormationRunChangesFromSimToNonSim_thenSimFootNotesAreCollapsed', () async {
      // ARRANGE
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: true),
          previousFormationRun: null,
        ),
      );
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);

      // ACT
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: false),
          previousFormationRun: _buildFormationRun(simTrain: true),
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenFormationRunChangesFromNonSimToSim_thenSimFootNotesAreExpanded', () async {
      // ARRANGE
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: false),
          previousFormationRun: null,
        ),
      );
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // ACT
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: true),
          previousFormationRun: _buildFormationRun(simTrain: false),
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenFormationRunIsSimTrain_thenNonSimFootNotesAreUnaffected', () async {
      // ARRANGE
      final initialState = testee.collapsedRowsValue.stateOf(footNoteData);

      // ACT
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: true),
          previousFormationRun: null,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(footNoteData), initialState);
    });

    test('simTrain_whenSimTrainAndPositionPassesSimFootNote_thenSimFootNoteIsNotCollapsed', () async {
      // ARRANGE
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: true),
          previousFormationRun: null,
        ),
      );
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);

      // ACT - advance position past simFootNoteData(8) and footNoteData(10)
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // EXPECT - SIM foot note must NOT be auto-collapsed
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenNoSimTrainAndPositionPassesSimFootNote_thenSimFootNoteRemainsCollapsed', () async {
      // ARRANGE
      formationRunSubject.add(
        FormationRunChange(
          formationRun: _buildFormationRun(simTrain: false),
          previousFormationRun: null,
        ),
      );
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // ACT
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // EXPECT
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenFormationRunIsNull_thenSimFootNotesAreCollapsed', () async {
      // ARRANGE & ACT - formationRunSubject starts with null (seeded in setUp)
      await processStreams();

      // EXPECT - SIM foot note is collapsed when there is no formation run
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });
  });
}

FormationRun _buildFormationRun({required bool simTrain}) {
  return FormationRun(
    inspectionDateTime: DateTime(2026),
    tafTapLocationReferenceStart: 'START',
    tafTapLocationReferenceEnd: 'END',
    tractionLengthInCm: 0,
    hauledLoadLengthInCm: 0,
    formationLengthInCm: 0,
    tractionWeightInT: 0,
    hauledLoadWeightInT: 0,
    formationWeightInT: 0,
    tractionBrakedWeightInT: 0,
    hauledLoadBrakedWeightInT: 0,
    formationBrakedWeightInT: 0,
    tractionHoldingForceInHectoNewton: 0,
    formationHoldingForceInHectoNewton: 0,
    simTrain: simTrain,
    carCarrierVehicle: false,
    dangerousGoods: false,
    vehiclesCount: 0,
    vehiclesWithBrakeDesignLlAndKCount: 0,
    vehiclesWithBrakeDesignDCount: 0,
    vehiclesWithDisabledBrakesCount: 0,
    axleLoadMaxInKg: 0,
    gradientUphillMaxInPermille: 0,
    gradientDownhillMaxInPermille: 0,
  );
}
