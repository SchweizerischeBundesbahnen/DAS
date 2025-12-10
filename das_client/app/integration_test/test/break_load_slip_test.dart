import 'package:app/di/di.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_page.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_header.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/journey_table/widgets/journey_table.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';

import '../app_test.dart';
import '../mocks/mock_formation_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('breakSlip_whenNoDataAvailable_doesNotShowExtendedMenuItem', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999');

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;

    // Open extended menu
    await openExtendedMenu(tester);
    expect(find.text(l10n.w_extended_menu_breaking_slip_action), findsNothing);
    await dismissExtendedMenu(tester);

    formationRepository.emitT9999Formation();
    await tester.pumpAndSettle();

    await openExtendedMenu(tester);
    expect(find.text(l10n.w_extended_menu_breaking_slip_action), findsOneWidget);
    await dismissExtendedMenu(tester);

    await disconnect(tester);
  });

  testWidgets('breakSlip_showsInformationAndNavigation', (tester) async {
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    await openBreakSlipPage(tester);

    expect(find.byType(BreakLoadSlipPage), findsOneWidget);
    expect(find.text('T9999'), findsOneWidget);

    // Check resolved stations
    expect(find.text('Bahnhof A'), findsOneWidget);
    expect(find.text('Haltestelle B'), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.text('Haltestelle B'), findsOneWidget);
    expect(find.text('Halt auf Verlangen C'), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.text('Halt auf Verlangen C'), findsOneWidget);
    expect(find.text('Klammerbahnhof D'), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonPreviousKey));

    expect(find.text('Haltestelle B'), findsOneWidget);
    expect(find.text('Halt auf Verlangen C'), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('breakSlip_whenSpecialIndicatorsArePresent_showsBanners', (tester) async {
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    await openBreakSlipPage(tester);

    expect(find.byKey(BreakLoadSlipSpecialRestrictions.simTrainBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipHeader.simTrainHeaderBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipHeader.dangerousGoodsHeaderBannerKey), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BreakLoadSlipSpecialRestrictions.simTrainBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipHeader.simTrainHeaderBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipHeader.dangerousGoodsHeaderBannerKey), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BreakLoadSlipSpecialRestrictions.simTrainBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipHeader.simTrainHeaderBannerKey), findsNothing);
    expect(find.byKey(BreakLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipHeader.dangerousGoodsHeaderBannerKey), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BreakLoadSlipSpecialRestrictions.simTrainBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipHeader.simTrainHeaderBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipHeader.dangerousGoodsHeaderBannerKey), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BreakLoadSlipSpecialRestrictions.carCarrierBannerKey), findsOneWidget);
    expect(find.byKey(BreakLoadSlipHeader.carCarrierHeaderBannerKey), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('breakSlip_whenDifferentBreakSeriesInBreakSlip_showsNotification', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;

    expect(find.byKey(JourneyTable.differentBreakSeriesWarningKey), findsNothing);

    formationRepository.emitT9999Formation();
    await tester.pumpAndSettle();

    expect(find.byKey(JourneyTable.differentBreakSeriesWarningKey), findsOneWidget);

    await openBreakSlipPage(tester);

    await tapElement(tester, find.text(l10n.p_break_load_slip_button_apply_train_series));

    await closeBreakSlipPage(tester);

    expect(find.byKey(JourneyTable.differentBreakSeriesWarningKey), findsNothing);

    await disconnect(tester);
  });
}
