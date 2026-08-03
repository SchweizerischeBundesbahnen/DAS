import 'package:app/di/di.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_page.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_header_box.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_overview.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/brake_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/util/time_constants.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../mocks/mock_formation_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('brakeSlip_whenPositionUpdateWhileBrakeSlipPageOpen_thenDoesNotUpdateToNewPosition', (
    tester,
  ) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999');

    await openBrakeSlipPage(tester);

    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);
    expect(find.text('T9999'), findsOneWidget);

    // Check resolved stations
    expect(find.text('Bahnhof A'), findsOneWidget);
    expect(find.text('Haltestelle B'), findsOneWidget);

    // Wait 20 seconds for position updates
    await tester.pumpAndSettle();
    await Future.delayed(Duration(seconds: 20));
    await tester.pumpAndSettle();

    // Check still showing first page
    expect(find.text('Bahnhof A'), findsOneWidget);
    expect(find.text('Haltestelle B'), findsOneWidget);

    await closeBrakeSlipPage(tester);
    await tester.pumpAndSettle();

    await waitUntilExists(
      tester,
      find.descendant(of: findDASTableRowByText('Halt auf Verlangen C'), matching: find.byType(RouteChevron)),
    );

    await openBrakeSlipPage(tester);

    expect(find.byType(BrakeLoadSlipPage), findsOne);

    await tester.pumpAndSettle();

    expect(find.text('Bahnhof A'), findsNothing);
    expect(find.text('Halt auf Verlangen C'), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_whenNoDataAvailable_thenDoesNotShowButton', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999');

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;

    expect(find.text(l10n.p_journey_header_button_brake_slip), findsNothing);

    formationRepository.emitT9999Formation();
    await tester.pumpAndSettle();

    expect(find.text(l10n.p_journey_header_button_brake_slip), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_whenFormationDataLoaded_thenShowsInformationAndNavigation', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    await openBrakeSlipPage(tester);

    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);
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

  testWidgets('brakeSlip_whenSpecialIndicatorsArePresent_thenShowsBanners', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    await openBrakeSlipPage(tester);

    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.simTrainBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipHeaderBox.simTrainHeaderBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipHeaderBox.dangerousGoodsHeaderBannerKey), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.simTrainBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipHeaderBox.simTrainHeaderBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipHeaderBox.dangerousGoodsHeaderBannerKey), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.simTrainBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipHeaderBox.simTrainHeaderBannerKey), findsNothing);
    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipHeaderBox.dangerousGoodsHeaderBannerKey), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.simTrainBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipHeaderBox.simTrainHeaderBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.dangerousGoodsBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipHeaderBox.dangerousGoodsHeaderBannerKey), findsOneWidget);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byKey(BrakeLoadSlipSpecialRestrictions.carCarrierBannerKey), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipHeaderBox.carCarrierHeaderBannerKey), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_whenDifferentBrakeSeriesInFormation_thenShowsNotification', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;

    expect(find.byKey(JourneyTable.differentBrakeSeriesWarningKey), findsNothing);

    formationRepository.emitT9999Formation();
    await tester.pumpAndSettle();

    expect(find.byKey(JourneyTable.differentBrakeSeriesWarningKey), findsOneWidget);

    await openBrakeSlipPage(tester);

    await tapElement(tester, find.text(l10n.p_brake_load_slip_button_apply_train_series));

    await closeBrakeSlipPage(tester);

    expect(find.byKey(JourneyTable.differentBrakeSeriesWarningKey), findsNothing);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_whenOpened_thenDisplaysCorrectInformation', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);

    expect(find.byKey(BrakeLoadSlipModalBuilder.headerKey), findsOneWidget);
    expect(find.text(l10n.p_brake_load_slip_special_restrictions_title), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipModalBuilder.buttonKey), findsOneWidget);

    final overview = find.byType(BrakeLoadSlipModalOverview);
    expect(find.descendant(of: overview, matching: find.text(l10n.p_brake_load_slip_train_data_from)), findsOneWidget);
    expect(find.descendant(of: overview, matching: find.text('Bahnhof A')), findsOneWidget);
    expect(find.descendant(of: overview, matching: find.text(l10n.p_brake_load_slip_train_data_to)), findsOneWidget);
    expect(find.descendant(of: overview, matching: find.text('Haltestelle B')), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_whenIdleTimeoutElapses_thenNeverClosesAutomatically', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    final waitTime = DI.get<TimeConstants>().modalSheetAutomaticCloseAfterSeconds + 1;

    // brake/load slip modal will never close on its own
    await Future.delayed(Duration(seconds: waitTime));
    await tester.pumpAndSettle();

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_whenButtonTappedWhileOpen_thenClosesModal', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    // tapping the button that opened the modal a second time closes it
    await tapElement(tester, find.byIcon(SBBIcons.freight_wagon_container_medium));
    await tester.pumpAndSettle();

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_whenNonInteractiveAreaTapped_thenClosesModal', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    // tapping a non-interactive area inside the modal (its title) closes it, without needing the "x"
    await tapElement(tester, find.byKey(BrakeLoadSlipModalBuilder.headerKey), warnIfMissed: false);

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_whenFullscreenButtonTapped_thenOpensFullscreen', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);

    await tapElement(tester, find.byKey(BrakeLoadSlipModalBuilder.buttonKey));

    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_whenFormationUpdated_thenShowsNotification', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');
    await Future.delayed(BrakeLoadSlipViewModel.initialNotificationDelay);

    expect(find.byKey(BrakeLoadSlipNotification.brakeLoadSlipNotificationKey), findsNothing);

    formationRepository.emitT9999FormationUpdate();
    await tester.pumpAndSettle();

    expect(find.byKey(BrakeLoadSlipNotification.brakeLoadSlipNotificationKey), findsOneWidget);

    await tapElement(tester, find.byKey(BrakeLoadSlipNotification.brakeLoadSlipNotificationKey));

    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);

    await closeBrakeSlipPage(tester);

    expect(find.byType(JourneyPage), findsOneWidget);
    expect(find.byKey(BrakeLoadSlipNotification.brakeLoadSlipNotificationKey), findsNothing);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_whenFormationRunChanged_thenUpdatesRunChangeDisplay', (tester) async {
    await IntegrationTestApp.start(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    await openBrakeSlipPage(tester);

    expect(find.byType(DotIndicator), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byType(DotIndicator), findsNWidgets(4));

    formationRepository.emitFormationWithAllChanges();
    await tester.pumpAndSettle();

    expect(find.byType(DotIndicator), findsNothing);

    await tapElement(tester, find.byKey(NavigationButtons.navigationButtonNextKey));

    expect(find.byType(DotIndicator), findsNWidgets(38));

    await disconnect(tester);
  });
}
