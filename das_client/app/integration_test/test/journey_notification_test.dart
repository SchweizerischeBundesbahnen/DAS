import 'package:app/pages/journey/journey_table/widgets/notification/disturbance_notification.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey notification test', () {
    testWidgets('test koa notifications are displayed properly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T13');

      await waitUntilExists(tester, find.text(l10n.w_koa_notification_wait));

      await waitUntilExists(tester, find.text(l10n.w_koa_notification_wait_canceled));

      await waitUntilNotExists(tester, find.text(l10n.w_koa_notification_wait_canceled));

      await disconnect(tester);
    });

    testWidgets('test departure process modal sheet is displayed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T13');

      await waitUntilExists(tester, find.text(l10n.w_koa_notification_wait));

      await tapElement(tester, find.text(l10n.w_koa_notification_departure_process));

      expect(find.text(l10n.w_departure_process_modal_sheet_title), findsOneWidget);
      expect(find.text(l10n.w_departure_process_modal_sheet_content), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test disturbance notification', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T33');

      await waitUntilExists(tester, find.byKey(DisturbanceNotification.disturbanceNotificationKey));
      await waitUntilNotExists(tester, find.byKey(DisturbanceNotification.disturbanceNotificationKey));

      await disconnect(tester);
    });
  });
}
