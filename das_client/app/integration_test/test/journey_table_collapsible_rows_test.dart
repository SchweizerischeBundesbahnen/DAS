import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_operational_indication_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/foot_note_accordion.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/scrollable_align.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../mocks/mock_formation_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test operational indication collapsible', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T22M');

    final dataToTest = UncodedOperationalIndication(order: 0, texts: ['Renens VD: Halt an Halteort 3']);
    final identifier = dataToTest.hashCode;
    await _checkCollapsible(identifier, tester);

    await disconnect(tester);
  });
  testWidgets('test RADN foot note collapsible', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T15M');

    final footnote = FootNote(
      type: .decisiveGradientDown,
      refText: '1)',
      text: 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰',
    );
    final opFootNote = OpFootNote(order: 0, footNote: footnote);
    final identifier = opFootNote.hashCode;
    await _checkCollapsible(identifier, tester);

    await disconnect(tester);
  });
  testWidgets('test show more on long texts of operational indications', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T22M');

    final textToSearch = 'Pully: Vorziehen bis Ende Perron.';

    // scroll to testable row
    await dragUntilTextInStickyHeader(tester, 'Pully');

    // should not be collapsed by default
    final accordion = _findDASTableAccordionByContainsText(textToSearch, UncodedOperationalIndicationAccordion);
    _checkCollapsibleRow(isCollapsed: false, collapsibleRow: accordion);

    // should have show more button and collapsed content
    final collapsedContent = find.descendant(
      of: accordion,
      matching: find.byKey(UncodedOperationalIndicationAccordion.collapsedContentKey),
    );
    expect(collapsedContent, findsOneWidget);
    var showMoreButton = find.descendant(
      of: accordion,
      matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreTextKey),
    );
    expect(showMoreButton, findsOneWidget);

    // should show full text after tap on row and no button
    await tapElement(tester, showMoreButton);
    await tester.pumpAndSettle(ScrollableAlign.alignScrollDuration);

    final rowWithExpandedText = _findDASTableAccordionByContainsText(
      'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      UncodedOperationalIndicationAccordion,
    );
    expect(rowWithExpandedText, findsOneWidget);
    showMoreButton = find.descendant(
      of: rowWithExpandedText,
      matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreTextKey),
    );
    expect(showMoreButton, findsNothing);

    await disconnect(tester);
  });
  testWidgets('test combined operational indications and replaced new lines with " ;"', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T22M');

    // scroll to testable row
    await dragUntilTextInStickyHeader(tester, 'Lausanne');

    // should have show more button and collapsed content with " ;" delimiter
    final accordion = _findDASTableAccordionByContainsText(
      'Strecke INN - MR: Bahnübergangsanlagen ohne Balisenüberwachung; Straba. = Strassenbahnbereich;',
      UncodedOperationalIndicationAccordion,
    );
    final collapsedContent = find.descendant(
      of: accordion,
      matching: find.byKey(UncodedOperationalIndicationAccordion.collapsedContentKey),
    );
    expect(collapsedContent, findsOneWidget);
    final showMoreButton = find.descendant(
      of: accordion,
      matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreTextKey),
    );
    expect(showMoreButton, findsOneWidget);

    // should show full content without " ;" after tap on show more
    await tapElement(tester, accordion);
    final expandedRow = _findDASTableAccordionByContainsText(
      'Strecke INN - MR: Bahnübergangsanlagen ohne Balisenüberwachung\nStraba. = Strassenbahnbereich',
      UncodedOperationalIndicationAccordion,
    );
    expect(expandedRow, findsOneWidget);

    // should show text of combined operational indication
    final combinedText = find.descendant(
      of: expandedRow,
      matching: find.textContaining('Lausanne: Halt an Halteort 2'),
    );
    expect(combinedText, findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test row combined for operational indication and foot note on same service point', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T22M');

    final scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(
      find.byKey(CombinedFootNoteOperationalIndicationRow.rowKey),
      scrollableFinder,
      const Offset(0, -100),
    );

    final combinedRow = find.byKey(CombinedFootNoteOperationalIndicationRow.rowKey);
    expect(combinedRow, findsOneWidget);

    final operationalIndicationRow = find.descendant(
      of: combinedRow,
      matching: find.textContaining(l10n.c_uncoded_operational_indication),
    );
    expect(operationalIndicationRow, findsOneWidget);

    final footNoteRow = find.descendant(
      of: combinedRow,
      matching: find.textContaining(l10n.c_radn),
    );
    expect(footNoteRow, findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test operational indication collapsed when passed', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T22');

    final dataToTest = UncodedOperationalIndication(order: 0, texts: ['Renens VD: Halt an Halteort 3']);
    final identifier = dataToTest.hashCode;
    await _checkCollapsedWhenPassed(identifier, tester);

    await disconnect(tester);
  });
  testWidgets('test RADN foot notes collapsed when passed', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T15');

    final footnote = FootNote(
      type: .decisiveGradientDown,
      refText: '1)',
      text: 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰',
    );
    final opFootNote = OpFootNote(order: 0, footNote: footnote);
    final identifier = opFootNote.hashCode;

    await _checkCollapsedWhenPassed(identifier, tester);

    await disconnect(tester);
  });

  testWidgets('test RADN foot notes title contain type', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T15M');

    expect(find.textContaining(l10n.c_radn_type_decisive_gradient_down), findsOneWidget);
    expect(find.textContaining(l10n.c_radn_type_journey), findsAny);

    await disconnect(tester);
  });

  testWidgets('simFootNote_whenNoBrakeLoadSlip_thenSimFootNoteIsCollapsed', (tester) async {
    // ARRANGE - no formation emitted (MockFormationRepository seeded with null)
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T20M');

    // scroll to the SIM foot note
    await dragUntilTextInStickyHeader(tester, 'Reichenbach im Kandertal');

    // EXPECT - SIM foot note accordion is collapsed
    final simFootNoteAccordion = _findDASTableAccordionByContainsText(l10n.c_radn_sim, FootNoteAccordion);
    _checkCollapsibleRow(isCollapsed: true, collapsibleRow: simFootNoteAccordion);

    await disconnect(tester);
  });

  testWidgets('simFootNote_whenBrakeLoadSlipWithoutSimTrain_thenSimFootNoteIsCollapsed', (tester) async {
    // ARRANGE - emit formation with simTrain: false
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT20NonSimFormation();

    await loadJourney(tester, trainNumber: 'T20M');
    await tester.pumpAndSettle();

    // scroll to the SIM foot note
    await dragUntilTextInStickyHeader(tester, 'Reichenbach im Kandertal');

    // EXPECT - SIM foot note accordion is collapsed
    final simFootNoteAccordion = _findDASTableAccordionByContainsText(l10n.c_radn_sim, FootNoteAccordion);
    _checkCollapsibleRow(isCollapsed: true, collapsibleRow: simFootNoteAccordion);

    await disconnect(tester);
  });

  testWidgets('simFootNote_whenSimTrainFormation_thenSimFootNoteIsExpandedAndNotCollapsedWhenPassed', (tester) async {
    // ARRANGE - emit formation with simTrain: true
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT20SimFormation();

    await loadJourney(tester, trainNumber: 'T20');
    await tester.pumpAndSettle();

    // scroll to the SIM foot note
    await dragUntilTextInStickyHeader(tester, 'Reichenbach im Kandertal');

    // EXPECT - SIM foot note is expanded
    final simFootNoteAccordion = _findDASTableAccordionByContainsText(l10n.c_radn_sim, FootNoteAccordion);
    _checkCollapsibleRow(isCollapsed: false, collapsibleRow: simFootNoteAccordion);

    // ACT - wait for automatic position advancement to reach Kandergrund
    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('Kandergrund'), matching: find.byKey(RouteChevron.chevronKey)),
    );
    await stopAutomaticAdvancement(tester);
    final scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(findDASTableRowByText('P111'), scrollableFinder, const Offset(0, 100));

    // EXPECT - SIM foot note must still be expanded (not auto-collapsed)
    final simFootNoteAccordionAfterPass = _findDASTableAccordionByContainsText(l10n.c_radn_sim, FootNoteAccordion);
    _checkCollapsibleRow(isCollapsed: false, collapsibleRow: simFootNoteAccordionAfterPass);

    await disconnect(tester);
  });
}

Future<void> _checkCollapsible(int identifier, WidgetTester tester) async {
  // should be expanded by default
  _checkCollapsibleRow(identifier: identifier, isCollapsed: false);

  // should be collapsed after tap
  await tapElement(tester, _findDASTableAccordionRowByKey(identifier), warnIfMissed: false);
  _checkCollapsibleRow(identifier: identifier, isCollapsed: true);

  // should be reopened after tap
  await tapElement(tester, _findDASTableAccordionRowByKey(identifier), warnIfMissed: false);
  _checkCollapsibleRow(identifier: identifier, isCollapsed: false);
}

Future<void> _checkCollapsedWhenPassed(int identifier, WidgetTester tester) async {
  // should be expanded by default
  _checkCollapsibleRow(identifier: identifier, isCollapsed: false);

  // wait for positional update and scroll back up
  await tester.pumpAndSettle(Duration(seconds: 2));
  await tester.drag(find.byType(AnimatedList), const Offset(0, 300));

  _checkCollapsibleRow(identifier: identifier, isCollapsed: true);
}

void _checkCollapsibleRow({required bool isCollapsed, Object? identifier, Finder? collapsibleRow}) {
  final rowToTest = collapsibleRow ?? _findDASTableAccordionRowByKey(identifier!);

  final accordions = find.descendant(
    of: rowToTest,
    matching: find.byKey(isCollapsed ? Accordion.collapsedKey : Accordion.expandedKey),
  );

  expect(accordions, findsAny);
}

Finder _findDASTableAccordionRowByKey(Object identifier) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.byKey(ObjectKey(identifier)), matching: find.byKey(DASTable.rowKey)),
  );
}

Finder _findDASTableAccordionByContainsText(String text, Type accordion) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.textContaining(text, findRichText: true), matching: find.byType(accordion)),
  );
}
