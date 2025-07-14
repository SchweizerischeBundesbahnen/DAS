import 'package:app/pages/journey/train_journey/widgets/table/uncoded_operational_indication_accordion.dart';
import 'package:app/widgets/accordion/accordion.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  // testWidgets('test operational indication collapsible', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T22M');
  //
  //   final dataToTest = UncodedOperationalIndication(order: 0, texts: ['Renens VD: Halt an Halteort 3']);
  //   final identifier = dataToTest.hashCode;
  //   await _checkCollapsible(identifier, tester);
  //
  //   await disconnect(tester);
  // });
  // testWidgets('test RADN foot note collapsible', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T15M');
  //
  //   final footnote = FootNote(
  //     type: FootNoteType.decisiveGradientDown,
  //     refText: '1)',
  //     text: 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰',
  //   );
  //   final opFootNote = OpFootNote(order: 0, footNote: footnote);
  //   final identifier = opFootNote.hashCode;
  //   await _checkCollapsible(identifier, tester);
  //
  //   await disconnect(tester);
  // });
  testWidgets('test show more on long texts of operational indications', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T22M');

    final textToSearch = 'Pully: Vorziehen bis Ende Perron.';

    // scroll to testable row
    await dragUntilTextInStickyHeader(tester, 'Pully');

    // should not be collapsed by default
    final collapsibleRow = _findDASTableAccordionRowByContainsText(textToSearch);
    _checkCollapsibleRow(isCollapsed: false, collapsibleRow: collapsibleRow);

    // should have show more button and collapsed content
    final collapsedContent = find.descendant(
      of: collapsibleRow,
      matching: find.byKey(UncodedOperationalIndicationAccordion.collapsedContentKey),
    );
    expect(collapsedContent, findsOneWidget);
    var showMoreButton = find.descendant(
      of: collapsibleRow,
      matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreButtonKey),
    );
    expect(showMoreButton, findsOneWidget);

    // should show full text after tap on "show more" and no button
    await tapElement(tester, showMoreButton);
    final rowWithEndOfText = _findDASTableAccordionRowByContainsText(
      'Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.',
    );
    expect(rowWithEndOfText, findsOneWidget);
    showMoreButton = find.descendant(
      of: collapsibleRow,
      matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreButtonKey),
    );
    expect(showMoreButton, findsNothing);

    await disconnect(tester);
  });
  // testWidgets('test combined operational indications and replaced new lines with " ;"', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T22M');
  //
  //   // scroll to testable row
  //   final scrollableFinder = find.byType(AnimatedList);
  //   await tester.dragUntilVisible(find.textContaining('Strecke INN - MR'), scrollableFinder, const Offset(0, -100));
  //
  //   // should have show more button and collapsed content with " ;" delimiter
  //   final collapsibleRow = _findDASTableAccordionRowByContainsText(
  //     'Strecke INN - MR: Bahnübergangsanlagen ohne Balisenüberwachung; Straba. = Strassenbahnbereich;',
  //   );
  //   final collapsedContent = find.descendant(
  //     of: collapsibleRow,
  //     matching: find.byKey(UncodedOperationalIndicationAccordion.collapsedContentKey),
  //   );
  //   expect(collapsedContent, findsOneWidget);
  //   final showMoreButton = find.descendant(
  //     of: collapsibleRow,
  //     matching: find.byKey(UncodedOperationalIndicationAccordion.showMoreButtonKey),
  //   );
  //   expect(showMoreButton, findsOneWidget);
  //
  //   // should show full content without " ;" after tap on show more
  //   await tapElement(tester, showMoreButton);
  //   final expandedRow = _findDASTableAccordionRowByContainsText(
  //     'Strecke INN - MR: Bahnübergangsanlagen ohne Balisenüberwachung\nStraba. = Strassenbahnbereich',
  //   );
  //   expect(expandedRow, findsOneWidget);
  //
  //   // should show text of combined operational indication
  //   final combinedText = find.descendant(
  //     of: expandedRow,
  //     matching: find.textContaining('Lausanne: Halt an Halteort 2'),
  //   );
  //   expect(combinedText, findsOneWidget);
  //
  //   await disconnect(tester);
  // });
  // testWidgets('test row combined for operational indication and foot note on same service point', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T22M');
  //
  //   final scrollableFinder = find.byType(AnimatedList);
  //   await tester.dragUntilVisible(
  //     find.byKey(CombinedFootNoteOperationalIndicationRow.rowKey),
  //     scrollableFinder,
  //     const Offset(0, -100),
  //   );
  //
  //   final combinedRow = find.byKey(CombinedFootNoteOperationalIndicationRow.rowKey);
  //   expect(combinedRow, findsOneWidget);
  //
  //   final operationalIndicationRow = find.descendant(
  //     of: combinedRow,
  //     matching: find.textContaining(l10n.c_uncoded_operational_indication),
  //   );
  //   expect(operationalIndicationRow, findsOneWidget);
  //
  //   final footNoteRow = find.descendant(
  //     of: combinedRow,
  //     matching: find.textContaining(l10n.c_radn),
  //   );
  //   expect(footNoteRow, findsOneWidget);
  //
  //   await disconnect(tester);
  // });
  // testWidgets('test operational indication collapsed when passed', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T22');
  //
  //   final dataToTest = UncodedOperationalIndication(order: 0, texts: ['Renens VD: Halt an Halteort 3']);
  //   final identifier = dataToTest.hashCode;
  //   await _checkCollapsedWhenPassed(identifier, tester);
  //
  //   await disconnect(tester);
  // });
  // testWidgets('test RADN foot notes collapsed when passed', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T15');
  //
  //   final footnote = FootNote(
  //     type: FootNoteType.decisiveGradientDown,
  //     refText: '1)',
  //     text: 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰',
  //   );
  //   final opFootNote = OpFootNote(order: 0, footNote: footnote);
  //   final identifier = opFootNote.hashCode;
  //
  //   await _checkCollapsedWhenPassed(identifier, tester);
  //
  //   await disconnect(tester);
  // });
  // testWidgets('test RADN foot notes collapsed when passed', (tester) async {
  //   await prepareAndStartApp(tester);
  //   await loadTrainJourney(tester, trainNumber: 'T15');
  //
  //   final footnote = FootNote(
  //     type: FootNoteType.decisiveGradientDown,
  //     refText: '1)',
  //     text: 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰',
  //   );
  //   final opFootNote = OpFootNote(order: 0, footNote: footnote);
  //   final identifier = opFootNote.hashCode;
  //
  //   await _checkCollapsedWhenPassed(identifier, tester);
  //
  //   await disconnect(tester);
  // });
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
  await tester.pumpAndSettle(Duration(seconds: 1));
  await tester.drag(find.byType(AnimatedList), const Offset(0, 300));

  _checkCollapsibleRow(identifier: identifier, isCollapsed: true);
}

void _checkCollapsibleRow({required bool isCollapsed, Object? identifier, Finder? collapsibleRow}) {
  final rowToTest = collapsibleRow ?? _findDASTableAccordionRowByKey(identifier!);
  final accordionState = find.descendant(
    of: rowToTest,
    matching: find.byKey(isCollapsed ? Accordion.collapsedKey : Accordion.expandedKey),
  );
  expect(accordionState, findsOneWidget);
}

Finder _findDASTableAccordionRowByKey(Object identifier) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.byKey(ObjectKey(identifier)), matching: find.byKey(DASTable.rowKey)),
  );
}

Finder _findDASTableAccordionRowByContainsText(String text) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.textContaining(text), matching: find.byKey(DASTable.rowKey)),
  );
}
