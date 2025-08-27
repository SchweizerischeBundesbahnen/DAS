import 'package:app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_train_journey.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train reduced journey test', () {
    patrolTest('test train information is displayed', (tester) async {
      await prepareAndStartApp(tester.tester);
      await loadTrainJourney(tester.tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester.tester);

      expect(find.text('T14 ${l10n.c_ru_sbb_p}'), findsAny);

      final formattedDate = Format.dateWithAbbreviatedDay(DateTime.now(), deviceLocale());
      expect(find.text(formattedDate), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('test passing and stopping points are displayed correctly', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester.tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Burgdorf')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Bern')), findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Zürich')), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('test duplicated asr is only displayed once', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester.tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 31.500 - km 32.400')), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('test network change is displayed', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester.tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(
        find.descendant(of: reducedJourneyTable, matching: find.byKey(CommunicationNetworkIcon.gsmPKey)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.byKey(CommunicationNetworkIcon.gsmRKey)),
        findsOneWidget,
      );

      await disconnect(tester.tester);
    });

    patrolTest('test planned times are displayed', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T16');

      await openReducedJourneyMenu(tester.tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;

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

      await disconnect(tester.tester);
    });
  });
}

Finder _findTableOfReducedJourney() {
  final reducedJourneyTable = find.byKey(ReducedTrainJourney.reducedJourneyTableKey);
  return find.descendant(of: reducedJourneyTable, matching: find.byKey(DASTable.tableKey));
}
