import 'dart:ui';

import 'package:app/app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/app/pages/journey/train_journey/widgets/reduced_overview/reduced_train_journey.dart';
import 'package:app/app/widgets/table/das_table.dart';
import 'package:app/util/format.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train reduced journey test', () {
    testWidgets('test train information is displayed', (tester) async {
      final testLocale = const Locale('de', 'CH');

      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester);

      expect(find.text('T14 SBB'), findsAny);

      final formattedDate = Format.dateWithAbbreviatedDay(DateTime.now(), testLocale);
      expect(find.text(formattedDate), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test passing and stopping points are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      await loadTrainJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Burgdorf')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Bern')), findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Zürich')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test duplicated asr is only displayed once', (tester) async {
      await prepareAndStartApp(tester);

      await loadTrainJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 31.500 - km 32.400')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test network change is displayed', (tester) async {
      await prepareAndStartApp(tester);

      await loadTrainJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.byKey(CommunicationNetworkIcon.gsmPKey)),
          findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.byKey(CommunicationNetworkIcon.gsmRKey)),
          findsOneWidget);

      await disconnect(tester);
    });
  });
}

Finder _findTableOfReducedJourney() {
  final reducedJourneyTable = find.byKey(ReducedTrainJourney.reducedJourneyTableKey);
  return find.descendant(of: reducedJourneyTable, matching: find.byKey(DASTable.tableKey));
}
