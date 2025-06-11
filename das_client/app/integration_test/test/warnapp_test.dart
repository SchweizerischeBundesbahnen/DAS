import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warnapp/component.dart';

import '../app_test.dart';
import '../data/warnapp_data.dart';
import '../util/test_utils.dart';

void main() {
  group('warnapp test', () {
    testWidgets('test warnapp gets triggered when signal is red', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataService = DI.get<MotionDataService>() as MockMotionDataService;
      motionDataService.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T17');

      await waitUntilExists(tester, find.byKey(WarnFunctionModalSheet.warnappModalSheetKey));

      await tapElement(tester, find.text(l10n.w_modal_sheet_warn_function_confirm_button));

      // Make sure the modal sheet is closed after confirmation
      expect(find.byKey(WarnFunctionModalSheet.warnappModalSheetKey), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test warnapp maneuver button activates maneuver mode', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataService = DI.get<MotionDataService>() as MockMotionDataService;
      motionDataService.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T17');

      await waitUntilExists(tester, find.byKey(WarnFunctionModalSheet.warnappModalSheetKey));

      await tapElement(tester, find.text(l10n.w_modal_sheet_warn_function_manoeuvre_button));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test warnapp does not get triggered while in maneuver mode', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataService = DI.get<MotionDataService>() as MockMotionDataService;
      motionDataService.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T17');

      final warappRepo = DI.get<WarnappRepository>();

      // check if warnapp is enabled
      expect(warappRepo.isEnabled, true);

      // activate maneuver mode
      await openExtendedMenu(tester);
      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);
      await tapElement(tester, find.byKey(ExtendedMenu.maneuverSwitchKey));
      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      // check if warnapp has been disabled
      expect(warappRepo.isEnabled, false);

      while (motionDataService.isReplayingEvents) {
        await tester.pump();
      }

      expect(find.byKey(WarnFunctionModalSheet.warnappModalSheetKey), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test warnapp does not get triggered when signal is green', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataService = DI.get<MotionDataService>() as MockMotionDataService;
      motionDataService.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T15');

      while (motionDataService.isReplayingEvents) {
        await tester.pump();
      }

      expect(find.byKey(WarnFunctionModalSheet.warnappModalSheetKey), findsNothing);

      await disconnect(tester);
    });
  });
}
