import 'package:app/di/di.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_page.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_header_box.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/brake_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';

import '../app_test.dart';
import '../mocks/mock_formation_repository.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('brakeSlip_whenNoDataAvailable_doesNotShowButton', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999');

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;

    expect(find.text(l10n.p_journey_header_button_brake_slip), findsNothing);

    formationRepository.emitT9999Formation();
    await tester.pumpAndSettle();

    expect(find.text(l10n.p_journey_header_button_brake_slip), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_showsInformationAndNavigation', (tester) async {
    await prepareAndStartApp(tester);

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

  testWidgets('brakeSlip_whenSpecialIndicatorsArePresent_showsBanners', (tester) async {
    await prepareAndStartApp(tester);

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

  testWidgets('brakeSlip_whenDifferentBrakeSeriesInBrakeSlip_showsNotification', (tester) async {
    await prepareAndStartApp(tester);
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

  testWidgets('brakeSlipModal_opensAndDisplayCorrectInformation', (tester) async {
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);

    expect(find.text(l10n.w_brake_load_slip_modal_title), findsOneWidget);
    expect(find.text(l10n.p_brake_load_slip_special_restrictions_title), findsOneWidget);
    expect(find.text(l10n.w_brake_load_slip_modal_open_brake_slip), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlipModal_openFullScreenFromModal', (tester) async {
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');

    // Open fullscreen
    await openBrakeSlipPage(tester);
    await closeBrakeSlipPage(tester);

    // Open modal
    await openBrakeSlipPage(tester);

    await tapElement(tester, find.text(l10n.w_brake_load_slip_modal_open_brake_slip));

    expect(find.byType(BrakeLoadSlipPage), findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('brakeSlip_testFormationUpdateNotification', (tester) async {
    await prepareAndStartApp(tester);

    final formationRepository = DI.get<FormationRepository>() as MockFormationRepository;
    formationRepository.emitT9999Formation();

    await loadJourney(tester, trainNumber: 'T9999M');
    await Future.delayed(BrakeLoadSlipViewModel.notificationDelay);

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

  testWidgets('brakeSlip_testFormationRunChangeDisplay', (tester) async {
    await prepareAndStartApp(tester);

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
