import 'package:app/di.dart';
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

      final motionDataProvider = DI.get<MotionDataProvider>() as MockMotionDataProvider;
      motionDataProvider.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T17');

      await waitUntilExists(tester, find.byKey(WarnFunctionModalSheet.warnappModalSheetKey));

      await tapElement(tester, find.text(l10n.w_modal_sheet_warn_function_confirm_button));

      await disconnect(tester);
    });

    testWidgets('test warnapp gets triggered and opens maneuver mode', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataProvider = DI.get<MotionDataProvider>() as MockMotionDataProvider;
      motionDataProvider.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T17');

      await waitUntilExists(tester, find.byKey(WarnFunctionModalSheet.warnappModalSheetKey));

      await tapElement(tester, find.text(l10n.w_modal_sheet_warn_function_manoeuvre_button));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test warnapp does not get triggered when signal is green', (tester) async {
      await prepareAndStartApp(tester);

      final motionDataProvider = DI.get<MotionDataProvider>() as MockMotionDataProvider;
      motionDataProvider.updateMotionData(motionDataAbfahrt1);

      await loadTrainJourney(tester, trainNumber: 'T15');

      while (motionDataProvider.isReplayingEvents) {
        await tester.pump();
      }

      expect(find.byKey(WarnFunctionModalSheet.warnappModalSheetKey), findsNothing);

      await disconnect(tester);
    });
  });
}
