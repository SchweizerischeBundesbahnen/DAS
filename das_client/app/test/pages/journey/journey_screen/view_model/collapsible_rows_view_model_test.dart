import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/sim_train_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'collapsible_rows_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<JourneyViewModel>(), MockSpec<SimTrainViewModel>()])
void main() {
  late CollapsibleRowsViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockSimTrainViewModel mockSimTrainViewModel;
  late BehaviorSubject<Journey?> journeySubject;
  late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
  late BehaviorSubject<bool> simTrainSubject;

  final footNote = FootNote(text: 'Test footnote', identifier: 'FN1');
  final footNoteData = OpFootNote(order: 10, footNote: footNote);
  final footNote2 = FootNote(text: 'Second footnote', identifier: 'FN2');
  final footNoteData2 = OpFootNote(order: 20, footNote: footNote2);

  // SIM footnote: type == contact, refText == 'SIM'
  final simFootNote = FootNote(text: 'SIM note', identifier: 'SIM1', type: FootNoteType.contact, refText: 'SIM');
  final simFootNoteData = OpFootNote(order: 8, footNote: simFootNote);

  final indicator = OperationalIndication(order: 15, texts: ['Some indication']);
  final indicator2 = OperationalIndication(order: 25, texts: ['Another indication']);

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

    mockSimTrainViewModel = MockSimTrainViewModel();
    simTrainSubject = BehaviorSubject<bool>.seeded(false);
    when(mockSimTrainViewModel.isSimTrain).thenAnswer((_) => simTrainSubject.stream);
    when(mockSimTrainViewModel.isSimTrainValue).thenAnswer((_) => simTrainSubject.value);

    testee = CollapsibleRowsViewModel(
      journeyPositionStream: journeyPositionSubject.stream,
      simTrainViewModel: mockSimTrainViewModel,
      journeyViewModel: mockJourneyViewModel,
    );
  });

  tearDown(() {
    testee.dispose();
    journeySubject.close();
    journeyPositionSubject.close();
    simTrainSubject.close();
  });

  group('toggleRow', () {
    test('toggleRow_whenBaseFootNoteIsExpanded_thenCollapsesIt', () async {
      // GIVEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);

      // WHEN
      testee.toggleRow(footNoteData);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test('toggleRow_whenBaseFootNoteIsCollapsed_thenExpandsIt', () async {
      // GIVEN
      testee.toggleRow(footNoteData);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);

      // WHEN
      testee.toggleRow(footNoteData);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);
    });

    test('toggleRow_whenOperationalIndicationDefault_thenIsExpandedWithCollapsedContent', () async {
      // THEN
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
    });

    test(
      'toggleRow_whenOperationalIndicationIsExpandedWithCollapsedContentAndContentExpandable_thenExpands',
      () async {
        // GIVEN
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);

        // WHEN
        testee.toggleRow(indicator, isContentExpandable: true);
        await processStreams();

        // THEN
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expanded);
      },
    );

    test(
      'toggleRow_whenOperationalIndicationIsExpandedWithCollapsedContentAndContentNotExpandable_thenCollapses',
      () async {
        // GIVEN
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);

        // WHEN
        testee.toggleRow(indicator, isContentExpandable: false);
        await processStreams();

        // THEN
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
      },
    );

    test('toggleRow_whenOperationalIndicationIsExpanded_thenCollapses', () async {
      // GIVEN
      testee.toggleRow(indicator, isContentExpandable: true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expanded);

      // WHEN
      testee.toggleRow(indicator, isContentExpandable: true);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
    });

    test('toggleRow_whenOperationalIndicationIsCollapsed_thenExpandsToExpandedWithCollapsedContent', () async {
      // GIVEN
      testee.toggleRow(indicator);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);

      // WHEN
      testee.toggleRow(indicator);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
    });

    test('toggleRow_whenTogglingOneRow_thenOtherRowsAreUnaffected', () async {
      // GIVEN
      final initialStateIndicator = testee.collapsedRowsValue.stateOf(indicator);

      // WHEN
      testee.toggleRow(footNoteData);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(indicator), initialStateIndicator);
    });

    test('toggleRow_whenToggled_thenEmitsNewStateOnStream', () async {
      // GIVEN
      final emittedStates = <Map<int, CollapsedState>>[];
      final subscription = testee.collapsedRows.listen(emittedStates.add);
      await processStreams(); // flush the initial seeded value
      emittedStates.clear();

      // WHEN
      testee.toggleRow(footNoteData);
      await processStreams();

      // THEN
      expect(emittedStates.length, 1);
      expect(emittedStates.first.stateOf(footNoteData), CollapsedState.collapsed);

      await subscription.cancel();
    });
  });

  group('updatePassedAccordionRowsState', () {
    test('updatePassedAccordionRowsState_whenPositionAdvancesPastFootNote_thenFootNoteIsCollapsed', () async {
      // GIVEN - journey: signal1(5), footNoteData(10), indicator(15), footNoteData2(20), indicator2(25), signal2(30)

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2, // passed footNoteData(10)
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test(
      'updatePassedAccordionRowsState_whenPositionAdvancesPastOperationalIndication_thenIndicatorIsCollapsed',
      () async {
        // GIVEN

        // WHEN
        journeyPositionSubject.add(
          JourneyPositionModel(
            lastPosition: signal1,
            currentPosition: signalBetween2And3, // passed footNoteData(10) and indicator(15)
          ),
        );
        await processStreams();

        // THEN
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
      },
    );

    test(
      'updatePassedAccordionRowsState_whenPositionAdvancesOverMultipleCollapsibles_thenAllPassedAreCollapsed',
      () async {
        // GIVEN

        // WHEN
        journeyPositionSubject.add(
          JourneyPositionModel(
            lastPosition: signal1,
            currentPosition: signal2, // passed all collapsibles
          ),
        );
        await processStreams();

        // THEN
        expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(footNoteData2), CollapsedState.collapsed);
        expect(testee.collapsedRowsValue.stateOf(indicator2), CollapsedState.collapsed);
      },
    );

    test('updatePassedAccordionRowsState_whenPositionMovesBackwards_thenPassedRowsAreExpandedAgain', () async {
      // GIVEN - collapse rows while moving forward first
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween2And3,
        ),
      );
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.collapsed);

      // WHEN - move backwards over the same rows
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signalBetween2And3,
          currentPosition: signal1,
        ),
      );
      await processStreams();

      // THEN - collapsed rows are re-opened to their default state
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
    });

    test('updatePassedAccordionRowsState_whenMovingBackwardsOnNonSimTrain_thenSimFootNoteStaysCollapsed', () async {
      // GIVEN - non-SIM state keeps SIM foot note collapsed
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // WHEN - move backwards over the SIM foot note row
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signalBetween1And2,
          currentPosition: signal1,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('updatePassedAccordionRowsState_whenCurrentSameAsLast_thenNothingChanges', () async {
      // GIVEN
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signal1,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue, initialState);
    });

    test('updatePassedAccordionRowsState_whenLastPositionIsNull_thenNothingChanges', () async {
      // GIVEN
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: null,
          currentPosition: signal2,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue, initialState);
    });

    test('updatePassedAccordionRowsState_whenCurrentPositionIsNull_thenNothingChanges', () async {
      // GIVEN
      final initialState = Map<int, CollapsedState>.from(testee.collapsedRowsValue);

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: null,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue, initialState);
    });

    test('updatePassedAccordionRowsState_whenRowAlreadyCollapsed_thenRemainsCollapsed', () async {
      // GIVEN
      testee.toggleRow(footNoteData);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.collapsed);
    });

    test('updatePassedAccordionRowsState_whenFutureCollapsiblesNotYetPassed_thenTheyAreNotCollapsed', () async {
      // GIVEN

      // WHEN
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2, // only footNoteData(10) is passed
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(indicator), CollapsedState.expandedWithCollapsedContent);
      expect(testee.collapsedRowsValue.stateOf(footNoteData2), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(indicator2), CollapsedState.expandedWithCollapsedContent);
    });
  });

  group('simTrain', () {
    test('simTrain_whenSimTrainViewModelReturnsTrue_thenSimFootNotesAreExpanded', () async {
      // WHEN - emit true on stream
      simTrainSubject.add(true);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenSimTrainViewModelReturnsFalse_thenSimFootNotesAreCollapsed', () async {
      // WHEN - emit false on stream
      simTrainSubject.add(false);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenSimTrainChangesFromFalseToTrue_thenSimFootNotesAreExpanded', () async {
      // GIVEN - start with non-SIM
      simTrainSubject.add(false);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // WHEN - change to SIM
      simTrainSubject.add(true);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenSimTrainChangesFromTrueToFalse_thenSimFootNotesAreCollapsed', () async {
      // GIVEN - start with SIM
      simTrainSubject.add(true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);

      // WHEN - change to non-SIM
      simTrainSubject.add(false);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenSimTrain_thenNonSimFootNotesAreUnaffected', () async {
      // GIVEN
      simTrainSubject.add(true);
      await processStreams();

      // THEN - regular footnotes should remain in their default state
      expect(testee.collapsedRowsValue.stateOf(footNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenSimTrainAndPositionPassesSimFootNote_thenSimFootNoteIsNotCollapsed', () async {
      // GIVEN - SIM train
      simTrainSubject.add(true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);

      // WHEN - advance position past simFootNoteData(8) and footNoteData(10)
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // THEN - SIM foot note must NOT be auto-collapsed
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });

    test('simTrain_whenNoSimTrainAndPositionPassesSimFootNote_thenSimFootNoteRemainsCollapsed', () async {
      // GIVEN - non-SIM train (default is false)
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      // WHEN - advance position
      journeyPositionSubject.add(
        JourneyPositionModel(
          lastPosition: signal1,
          currentPosition: signalBetween1And2,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);
    });

    test('simTrain_whenStreamEmitsMultipleTimes_thenStateUpdatesAccordingly', () async {
      // WHEN & THEN - toggle between states
      simTrainSubject.add(true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);

      simTrainSubject.add(false);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.collapsed);

      simTrainSubject.add(true);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(simFootNoteData), CollapsedState.expanded);
    });
  });

  group('lineFootNotes', () {
    final lineFootNoteA = FootNote(text: 'Line foot note A', identifier: 'LFN_A');
    final lineFootNoteB = FootNote(text: 'Line foot note B', identifier: 'LFN_B');
    final lineFootNoteWithoutId = FootNote(text: 'Line foot note without identifier');
    final simLineFootNote = FootNote(
      text: 'SIM line foot note',
      identifier: 'LFN_SIM',
      type: FootNoteType.contact,
      refText: 'SIM',
    );

    final lineSignal1 = Signal(order: 100, kilometre: []);
    final lineA1 = LineFootNote(order: 110, footNote: lineFootNoteA, locationName: 'Bern');
    final simLine1 = LineFootNote(order: 115, footNote: simLineFootNote, locationName: 'Bern');
    final lineSignal2 = Signal(order: 120, kilometre: []);
    final lineA2 = LineFootNote(order: 130, footNote: lineFootNoteA, locationName: 'Thun');
    final lineB1 = LineFootNote(order: 135, footNote: lineFootNoteB, locationName: 'Thun');
    final simLine2 = LineFootNote(order: 137, footNote: simLineFootNote, locationName: 'Thun');
    final lineSignal3 = Signal(order: 140, kilometre: []);
    final lineA3 = LineFootNote(order: 150, footNote: lineFootNoteA, locationName: 'Spiez');
    final lineB2 = LineFootNote(order: 155, footNote: lineFootNoteB, locationName: 'Spiez');
    final lineWithoutId1 = LineFootNote(order: 160, footNote: lineFootNoteWithoutId, locationName: 'Spiez');
    final lineSignal4 = Signal(order: 170, kilometre: []);
    final lineWithoutId2 = LineFootNote(order: 180, footNote: lineFootNoteWithoutId, locationName: 'Frutigen');
    final lineSignal5 = Signal(order: 200, kilometre: []);

    final lineFootNoteMetadata = Metadata(
      trainIdentification: TrainIdentification(companyCode: '1285', trainNumber: '54', date: DateTime(2026, 10, 5)),
    );
    final lineFootNoteJourney = Journey(
      metadata: lineFootNoteMetadata,
      data: [
        lineSignal1,
        lineA1,
        simLine1,
        lineSignal2,
        lineA2,
        lineB1,
        simLine2,
        lineSignal3,
        lineA3,
        lineB2,
        lineWithoutId1,
        lineSignal4,
        lineWithoutId2,
        lineSignal5,
      ],
    );

    setUp(() async {
      journeySubject.add(lineFootNoteJourney);
      await processStreams();
    });

    test('collapsedRows_whenLineFootNoteIsRepeated_thenFirstIsExpandedAndRepetitionsAreCollapsed', () {
      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(lineA3), CollapsedState.collapsed);
    });

    test('collapsedRows_whenLineFootNoteFirstAppearsMidJourney_thenFirstIsExpandedAndRepetitionIsCollapsed', () {
      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineB1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineB2), CollapsedState.collapsed);
    });

    test('collapsedRows_whenLineFootNoteHasNoIdentifier_thenAllAreExpanded', () {
      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineWithoutId1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineWithoutId2), CollapsedState.expanded);
    });

    test('collapsedRows_whenNoSimTrain_thenRepeatedSimLineFootNoteIsCollapsed', () {
      // THEN
      expect(testee.collapsedRowsValue.stateOf(simLine1), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(simLine2), CollapsedState.collapsed);
    });

    test('collapsedRows_whenSimTrain_thenRepeatedSimLineFootNoteIsExpanded', () async {
      // WHEN
      simTrainSubject.add(true);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simLine1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(simLine2), CollapsedState.expanded);
    });

    test('toggleRow_whenRepeatedLineFootNoteIsCollapsed_thenExpandsIt', () async {
      // WHEN
      testee.toggleRow(lineA2);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.expanded);
    });

    test('toggleRow_whenRepeatedLineFootNoteIsExpanded_thenCollapsesIt', () async {
      // GIVEN
      testee.toggleRow(lineA2);
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.expanded);

      // WHEN
      testee.toggleRow(lineA2);
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.collapsed);
    });

    test('updatePassedAccordionRowsState_whenMovingBackwards_thenLineFootNotesAreResetToTheirDefault', () async {
      // GIVEN - collapse all line foot notes while moving forward
      testee.toggleRow(lineA2);
      await processStreams();
      journeyPositionSubject.add(JourneyPositionModel(lastPosition: lineSignal1, currentPosition: lineSignal5));
      await processStreams();
      expect(testee.collapsedRowsValue.stateOf(lineA1), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.collapsed);

      // WHEN
      journeyPositionSubject.add(JourneyPositionModel(lastPosition: lineSignal5, currentPosition: lineSignal1));
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(lineA3), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(lineB1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineB2), CollapsedState.collapsed);
      expect(testee.collapsedRowsValue.stateOf(lineWithoutId2), CollapsedState.expanded);
    });

    test('onJourneyUpdated_whenRepeatedLineFootNoteWasToggled_thenKeepsToggledState', () async {
      // GIVEN
      testee.toggleRow(lineA2);
      await processStreams();

      // WHEN
      journeySubject.add(Journey(metadata: lineFootNoteMetadata, data: [...lineFootNoteJourney.data]));
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.expanded);
    });

    test('onJourneyUpdated_whenNewRepetitionOfLineFootNoteIsAdded_thenNewRepetitionIsCollapsed', () async {
      // GIVEN
      final lineA4 = LineFootNote(order: 190, footNote: lineFootNoteA, locationName: 'Kandersteg');

      // WHEN
      journeySubject.add(Journey(metadata: lineFootNoteMetadata, data: [...lineFootNoteJourney.data, lineA4]));
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA4), CollapsedState.collapsed);
    });

    test('onJourneyUpdated_whenSimTrainAndNewRepetitionOfSimLineFootNoteIsAdded_thenNewRepetitionIsExpanded', () async {
      // GIVEN
      simTrainSubject.add(true);
      await processStreams();
      final simLine3 = LineFootNote(order: 190, footNote: simLineFootNote, locationName: 'Kandersteg');

      // WHEN
      journeySubject.add(Journey(metadata: lineFootNoteMetadata, data: [...lineFootNoteJourney.data, simLine3]));
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(simLine3), CollapsedState.expanded);
    });

    test('onJourneyChanged_whenNewTrainIsLoaded_thenRepeatedLineFootNotesAreCollapsedAgain', () async {
      // GIVEN
      testee.toggleRow(lineA2);
      await processStreams();

      // WHEN
      journeySubject.add(
        Journey(
          metadata: Metadata(
            trainIdentification: TrainIdentification(
              companyCode: '1285',
              trainNumber: '55',
              date: DateTime(2026, 10, 5),
            ),
          ),
          data: lineFootNoteJourney.data,
        ),
      );
      await processStreams();

      // THEN
      expect(testee.collapsedRowsValue.stateOf(lineA1), CollapsedState.expanded);
      expect(testee.collapsedRowsValue.stateOf(lineA2), CollapsedState.collapsed);
    });
  });
}
