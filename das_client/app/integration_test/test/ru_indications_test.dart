import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/indication_accordion.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ru_indications/component.dart';

import '../app_test.dart';
import '../mocks/mock_ru_indications_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('ruIndications_whenShouldReturnMockData_thenIndicationsAreShown', (tester) async {
    // ARRANGE
    await prepareAndStartApp(tester);
    (DI.get<RuIndicationsRepository>() as MockRuIndicationsRepository).shouldReturnMockData = true;

    // ACT
    await loadJourney(tester, trainNumber: 'T22M');

    // ASSERT - short mock text is visible in an expanded IndicationAccordion
    final shortTextAccordion = _findIndicationAccordionByText('This is a short mock RU indication description.');
    expect(shortTextAccordion, findsWidgets);

    // Check title
    expect(find.text('CH01118'), findsAny);

    final firstAccordion = shortTextAccordion.first;

    final expandedContent = find.descendant(
      of: firstAccordion,
      matching: find.byKey(IndicationAccordion.expandedContentKey),
    );
    expect(expandedContent, findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('ruIndications_whenLongTextWithLink_thenShowMoreIsVisible', (tester) async {
    // ARRANGE
    await prepareAndStartApp(tester);
    (DI.get<RuIndicationsRepository>() as MockRuIndicationsRepository).shouldReturnMockData = true;

    // ACT
    await loadJourney(tester, trainNumber: 'T22M');

    // ASSERT - long text accordion shows "show more" button and collapsed content
    final longTextAccordion = _findIndicationAccordionByText(
      'This is a long mock RU indication description containing a',
    );
    expect(longTextAccordion, findsWidgets);

    final accordion = longTextAccordion.first;
    final collapsedContent = find.descendant(
      of: accordion,
      matching: find.byKey(IndicationAccordion.collapsedContentKey),
    );
    expect(collapsedContent, findsOneWidget);

    final showMoreButton = find.descendant(
      of: accordion,
      matching: find.byKey(IndicationAccordion.showMoreTextKey),
    );
    expect(showMoreButton, findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('ruIndications_whenLongTextWithMarkdownLink_thenLinkLabelIsRendered', (tester) async {
    // ARRANGE
    await prepareAndStartApp(tester);
    (DI.get<RuIndicationsRepository>() as MockRuIndicationsRepository).shouldReturnMockData = true;

    // ACT
    await loadJourney(tester, trainNumber: 'T22M');

    // expand the long text accordion to see full text
    final showMoreButton = find.descendant(
      of: _findIndicationAccordionByText('This is a long mock RU indication description containing a').first,
      matching: find.byKey(IndicationAccordion.showMoreTextKey),
    );
    await tapElement(tester, showMoreButton);

    // ASSERT - the markdown link label "link" is rendered as rich text (not raw markdown syntax)
    final linkLabel = find.textContaining('link', findRichText: true);
    expect(linkLabel, findsWidgets);

    // Raw markdown syntax [link](...) must NOT appear
    final rawMarkdown = find.textContaining('[link](https://example.com)', findRichText: true);
    expect(rawMarkdown, findsNothing);

    await disconnect(tester);
  });

  testWidgets('ruIndications_whenLongTextExpanded_thenFullContentIsVisible', (tester) async {
    // ARRANGE
    await prepareAndStartApp(tester);

    (DI.get<RuIndicationsRepository>() as MockRuIndicationsRepository).shouldReturnMockData = true;
    // ACT
    await loadJourney(tester, trainNumber: 'T22M');

    // expand long text
    final showMoreButton = find.descendant(
      of: _findIndicationAccordionByText('This is a long mock RU indication description containing a').first,
      matching: find.byKey(IndicationAccordion.showMoreTextKey),
    );
    await tapElement(tester, showMoreButton);

    // ASSERT - full lorem ipsum text now visible
    final expandedAccordion = _findIndicationAccordionByText('Lorem ipsum dolor sit amet');
    expect(expandedAccordion, findsWidgets);

    final expandedContent = find.descendant(
      of: expandedAccordion.first,
      matching: find.byKey(IndicationAccordion.expandedContentKey),
    );
    expect(expandedContent, findsOneWidget);

    // No "show more" button should remain after expanding
    final showMoreAfterExpand = find.descendant(
      of: expandedAccordion.first,
      matching: find.byKey(IndicationAccordion.showMoreTextKey),
    );
    expect(showMoreAfterExpand, findsNothing);

    await disconnect(tester);
  });
}

Finder _findIndicationAccordionByText(String text) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(
      of: find.textContaining(text, findRichText: true),
      matching: find.byType(IndicationAccordion),
    ),
  );
}
