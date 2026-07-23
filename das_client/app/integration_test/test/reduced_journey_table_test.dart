import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/reduced_journey_table.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train reduced journey test', () {
    testWidgets('reducedJourney_whenNetworkChangePresent_thenDisplaysWithKm', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');
      await openReducedJourneyMenu(tester);

      final reducedTable = _findTableOfReducedJourney();

      // find gsm-P-Icon
      final gsmPKey = find.descendant(of: reducedTable, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPKey, findsOneWidget);

      // find gsm-R-Icons
      final gsmRIcons = find.descendant(of: reducedTable, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(gsmRIcons, findsNWidgets(2));

      // find communication network change row by text km 0.3
      final firstCommunicationNetworkChangeRow = find.descendant(of: reducedTable, matching: find.text('km 0.3'));
      expect(firstCommunicationNetworkChangeRow, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenLoaded_thenDisplaysTrainInformation', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester);

      expect(find.text('T14 ${l10n.c_ru_sbb_p}'), findsAny);

      final formattedDate = Format.dateWithAbbreviatedDay(DateTime.now(), appLocale());
      expect(find.text(formattedDate), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenShuntingMovementJourney_thenDisplaysTrainInformation', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T29');
      await openReducedJourneyMenu(tester);

      expect(find.text('T29R / T29 ${l10n.c_ru_sbb_p}'), findsAny);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenStoppingAndPassingPoints_thenDisplaysCorrectly', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Burgdorf')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Bern')), findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Zürich')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenDuplicatedAsr_thenDisplaysOnlyOnce', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 31.500 - km 32.400')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenLoaded_thenDisplaysPlannedTimes', (tester) async {
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
