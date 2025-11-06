import 'package:app/pages/journey/journey_table/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/reduced_overview/reduced_journey_table.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train reduced journey test', () {
    testWidgets('test network change with km is displayed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester);

      final reducedTable = _findTableOfReducedJourney();

      // find gsm-R-Icons
      final gsmRKey = find.descendant(of: reducedTable, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(gsmRKey, findsNWidgets(2));

      // find gsm-P-Icons
      final gsmPKey = find.descendant(of: reducedTable, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPKey, findsNWidgets(2));

      // find first communication network change row by text km 33.5
      final firstCommunicationNetworkChangeRow = find.descendant(of: reducedTable, matching: find.text('km 33.5'));
      expect(firstCommunicationNetworkChangeRow, findsOneWidget);

      // find second communication network change row by text km 84.9
      final secondCommunicationNetworkChangeRow = find.descendant(of: reducedTable, matching: find.text('km 84.9'));
      expect(secondCommunicationNetworkChangeRow, findsOneWidget);
    });

    testWidgets('test train information is displayed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester);

      expect(find.text('T14 ${l10n.c_ru_sbb_p}'), findsAny);

      final formattedDate = Format.dateWithAbbreviatedDay(DateTime.now(), appLocale());
      expect(find.text(formattedDate), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test train information of shunting movement journey is displayed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T29');
      await openReducedJourneyMenu(tester);

      expect(find.text('T29R / T29 ${l10n.c_ru_sbb_p}'), findsAny);

      await disconnect(tester);
    });

    testWidgets('test passing and stopping points are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Burgdorf')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Bern')), findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Zürich')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test duplicated asr is only displayed once', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 31.500 - km 32.400')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test planned times are displayed', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T16');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      final expectedPlannedHeaderLabel = l10n.p_journey_table_time_label_planned;

      // GEN AEROPORT
      expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);
      final expectedTimeGenAerPlanned = Format.plannedTime(DateTime.parse('2025-05-12T15:13:40Z'));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeGenAerPlanned)), findsOneWidget);

      // LAUSANNE
      final expectedTimeLausannePlanned = '${Format.plannedTime(DateTime.parse('2025-05-12T16:07:20Z'))}\n';
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeLausannePlanned)),
        findsOneWidget,
      );

      // MONTREUX should have both times
      final expectedTimeMontreuxPlanned =
          '${Format.plannedTime(DateTime.parse('2025-05-12T16:35:12Z'))}\n'
          '${Format.plannedTime(DateTime.parse('2025-05-12T16:36:12Z'))}';
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeMontreuxPlanned)),
        findsOneWidget,
      );

      await disconnect(tester);
    });
  });
}

Finder _findTableOfReducedJourney() {
  final reducedJourneyTable = find.byKey(ReducedJourneyTable.reducedJourneyTableKey);
  return find.descendant(of: reducedJourneyTable, matching: find.byKey(DASTable.tableKey));
}
