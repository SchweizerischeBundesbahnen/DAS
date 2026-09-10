import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/reduced_journey_table.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_settings_repository.dart';
import '../util/test_utils.dart';

void main() {
  group('train reduced journey test', () {
    testWidgets('reducedJourney_whenNetworkChangePresent_thenDisplaysWithKm|BG8f0zcWS1hA8UmHb6XJ|tests:356', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
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

    testWidgets('reducedJourney_whenLoaded_thenDisplaysTrainInformation|VAiBsV3JAXE2ISLmbuph|tests:626', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T14');
      await openReducedJourneyMenu(tester);

      expect(find.textContaining('T14 ${companySBBP.shortName}'), findsAny);

      final formattedDate = Format.dateWithAbbreviatedDay(DateTime.now(), appLocale());
      expect(find.textContaining(formattedDate), findsNWidgets(2));

      await disconnect(tester);
    });

    testWidgets(
      'reducedJourney_whenShuntingMovementJourney_thenDisplaysTrainInformation|hrT2S4iEd0EwnEdVvS14|tests:264',
      (tester) async {
        await IntegrationTestApp.start(tester);
        await loadJourney(tester, trainNumber: 'T29');
        await openReducedJourneyMenu(tester);

        expect(find.text('T29R / T29 ${companySBBP.shortName}'), findsAny);

        await disconnect(tester);
      },
    );

    testWidgets('reducedJourney_whenStoppingAndPassingPoints_thenDisplaysCorrectly|49ntMponGaH3d2TeFrAD|tests:626', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Burgdorf')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Bern')), findsOneWidget);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Zürich')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenDuplicatedAsr_thenDisplaysOnlyOnce|PcZSkX79OGMg0q3pQn5D|tests:626', (tester) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T14');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 31.500 - km 32.400')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenLoaded_thenDisplaysOperationalTimes|tk4DmRU7XmIasiG1Znwd|tests:84', (tester) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T16');

      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      final expectedHeaderLabel = l10n.p_journey_table_time_label_new;

      // GEN AEROPORT
      expect(find.text(expectedHeaderLabel), findsNWidgets(2));
      final expectedTimeGenAerPlanned = Format.operationalTime(DateTime.parse('2025-05-12T16:14:20Z'));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeGenAerPlanned)), findsOneWidget);

      // LAUSANNE
      final expectedTimeLausannePlanned = '${Format.operationalTime(DateTime.parse('2025-05-12T17:07:10Z'))}\n';
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeLausannePlanned)),
        findsOneWidget,
      );

      // MONTREUX should have both times
      final expectedTimeMontreuxPlanned =
          '${Format.operationalTime(DateTime.parse('2025-05-12T17:35:12Z'))}\n'
          '${Format.operationalTime(DateTime.parse('2025-05-12T17:36:42Z'))}';
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.text(expectedTimeMontreuxPlanned)),
        findsOneWidget,
      );

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenRouteVariantsPresent_thenDisplaysExpectedViaTexts|243:626|pSBiHPNaiwU3EWwuI8Wo', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T52');

      await openReducedJourneyMenu(tester);

      expect(
        find.descendant(
          of: _findDasTableRowOfReducedJourney('Mattstetten (Abzw)'),
          matching: find.text(l10n.w_route_variant_nbs_bahn_2000_via_nbs),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _findDasTableRowOfReducedJourney('Wöschnau SBB'),
          matching: find.text(l10n.w_route_variant_eppenbergtunnel_via_eppenbergtunnel),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _findDasTableRowOfReducedJourney('Killwangen-Spreitenbach'),
          matching: find.text(l10n.w_route_variant_heitersberg_via_brugg_baden),
        ),
        findsOneWidget,
      );

      await disconnect(tester);
    });

    testWidgets('reducedJourney_whenFiltersToggled_thenDisplaysExpectedFilteredData|8gtxUlilUnE990rFs6TQ|tests:243', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T53');
      await openReducedJourneyMenu(tester);

      final reducedJourneyTable = _findTableOfReducedJourney();

      expect(find.text(l10n.w_filter_bar_option_indications), findsOneWidget);
      expect(find.text(l10n.w_filter_bar_option_protection_sections), findsOneWidget);
      expect(find.text(l10n.w_filter_bar_option_addition_speed_restrictions), findsOneWidget);
      expect(find.text(l10n.w_filter_bar_option_short_term_changes), findsOneWidget);
      expect(find.text(l10n.w_filter_bar_option_modifications), findsOneWidget);

      expect(
        find.descendant(of: reducedJourneyTable, matching: find.textContaining('Hinweise aus Betrieb')),
        findsOneWidget,
      );

      await tapElement(tester, find.text(l10n.w_filter_bar_option_indications));
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.textContaining('Hinweise aus Betrieb')),
        findsNothing,
      );

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 2.100 - km 4.900')), findsAny);
      await tapElement(tester, find.text(l10n.w_filter_bar_option_addition_speed_restrictions));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 2.100 - km 4.900')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Station 3')), findsOneWidget);
      await tapElement(tester, find.text(l10n.w_filter_bar_option_short_term_changes));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Station 3')), findsNothing);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 4.5')), findsOneWidget);
      await tapElement(tester, find.text(l10n.w_filter_bar_option_protection_sections));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 4.5')), findsNothing);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 2.5')), findsOneWidget);

      expect(find.descendant(of: reducedJourneyTable, matching: find.text('S2')), findsOneWidget);
      await tapElement(tester, find.text(l10n.w_filter_bar_option_modifications));
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('S2')), findsNothing);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 2.5')), findsNothing);

      await tapElement(tester, find.text(l10n.w_filter_bar_reset_button));
      expect(
        find.descendant(of: reducedJourneyTable, matching: find.textContaining('Hinweise aus Betrieb')),
        findsOneWidget,
      );
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('km 2.100 - km 4.900')), findsAny);
      expect(find.descendant(of: reducedJourneyTable, matching: find.text('Station 3')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets(
      'reducedJourney_whenFilterOptionHasNoElements_thenFilterOptionIsNotDisplayed|NcEa7zkv9QkRSKPNEBmV|tests:243',
      (
        tester,
      ) async {
        await IntegrationTestApp.start(tester);

        await loadJourney(tester, trainNumber: 'T35');
        await openReducedJourneyMenu(tester);

        expect(find.text(l10n.w_filter_bar_option_indications), findsNothing);
        expect(find.text(l10n.w_filter_bar_option_protection_sections), findsOne);
        expect(find.text(l10n.w_filter_bar_option_addition_speed_restrictions), findsNothing);
        expect(find.text(l10n.w_filter_bar_option_short_term_changes), findsNothing);
        expect(find.text(l10n.w_filter_bar_option_modifications), findsOne);
        expect(find.text(l10n.w_filter_bar_reset_button), findsOne);

        await disconnect(tester);
      },
    );

    testWidgets('reducedJourney_whenFilterHasNoData_thenFilterBarIsNotDisplayed|zp6yldzlCiYryWGLwxfy|tests:243', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      await loadJourney(tester, trainNumber: 'T52');
      await openReducedJourneyMenu(tester);

      expect(find.text(l10n.w_filter_bar_option_indications), findsNothing);
      expect(find.text(l10n.w_filter_bar_option_protection_sections), findsNothing);
      expect(find.text(l10n.w_filter_bar_option_addition_speed_restrictions), findsNothing);
      expect(find.text(l10n.w_filter_bar_option_short_term_changes), findsNothing);
      expect(find.text(l10n.w_filter_bar_option_modifications), findsNothing);
      expect(find.text(l10n.w_filter_bar_reset_button), findsNothing);

      await disconnect(tester);
    });
  });
}

Finder _findTableOfReducedJourney() {
  final reducedJourneyTable = find.byKey(ReducedJourneyTable.reducedJourneyTableKey);
  return find.descendant(of: reducedJourneyTable, matching: find.byKey(DASTable.tableKey));
}

Finder _findDasTableRowOfReducedJourney(String text) {
  final reducedJourneyTable = find.byKey(ReducedJourneyTable.reducedJourneyTableKey);
  return find.descendant(
    of: reducedJourneyTable,
    matching: find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey)),
  );
}
