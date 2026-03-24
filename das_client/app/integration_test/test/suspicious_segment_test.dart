import 'package:app/pages/journey/journey_screen/notification/widgets/suspicious_segment_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/suspicious_journey_point_row.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('suspicious segment tests', () {
    testWidgets('T40M shows suspicious segment rows and notification, dismiss hides notification', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T40M');

      expect(find.byKey(SuspiciousJourneyPointRow.rowKey), findsAny);
      expect(find.byKey(SuspiciousJourneyPointRow.firstRowKey), findsAny);

      expect(find.byKey(SuspiciousSegmentNotification.suspiciousSegmentNotificationKey), findsOneWidget);

      await tapElement(tester, find.byKey(SuspiciousSegmentNotification.dismissKey));

      expect(find.byKey(SuspiciousSegmentNotification.suspiciousSegmentNotificationKey), findsNothing);

      await disconnect(tester);
    });

    testWidgets('T40 notification disappears when all suspicious segments are passed and reappears on journey update', (
      tester,
    ) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T40');

      // Suspicious segment notification is initially visible
      expect(find.byKey(SuspiciousSegmentNotification.suspiciousSegmentNotificationKey), findsOneWidget);

      // Wait until the journey has updated and then all segments have passed – notification disappears
      await waitUntilNotExists(
        tester,
        find.byKey(SuspiciousSegmentNotification.suspiciousSegmentNotificationKey),
      );

      // A new journey update re-introduces suspicious segments – notification reappears
      await waitUntilExists(
        tester,
        find.byKey(SuspiciousSegmentNotification.suspiciousSegmentNotificationKey),
      );

      await disconnect(tester);
    });
  });
}
