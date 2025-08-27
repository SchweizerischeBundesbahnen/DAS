import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey notification test', () {
    patrolTest('test koa notifications are displayed properly', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T13');

      await waitUntilExists(tester.tester, find.text(l10n.w_koa_notification_wait));

      await waitUntilExists(tester.tester, find.text(l10n.w_koa_notification_wait_canceled));

      await waitUntilNotExists(tester.tester, find.text(l10n.w_koa_notification_wait_canceled));

      await disconnect(tester.tester);
    });

    patrolTest('test departure process modal sheet is displayed', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T13');

      await waitUntilExists(tester.tester, find.text(l10n.w_koa_notification_wait));

      await tapElement(tester.tester, find.text(l10n.w_koa_notification_departure_process));

      expect(find.text(l10n.w_departure_process_modal_sheet_title), findsOneWidget);
      expect(find.text(l10n.w_departure_process_modal_sheet_content), findsOneWidget);

      await disconnect(tester.tester);
    });
  });
}
