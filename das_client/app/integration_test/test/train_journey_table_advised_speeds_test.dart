import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/header/das_chronograph.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/advised_speed_cell_body.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test advised speed notification displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T24');

    // Check that there is no advised speed notification
    expect(find.byKey(AdvisedSpeedNotification.advisedSpeedNotificationKey), findsNothing);

    // 1st advised speed Message (check speed)
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText('80'));
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText(l10n.w_advised_speed_end));

    // 2nd advised speed Message (check signal)
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText('A653'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // 3rd advised speed Message (check icon & service point)
    await waitUntilExists(tester, find.byKey(AdvisedSpeedNotification.advisedSpeedNotificationIconKey));
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText('Morges'));
    // Punctuality Hidden
    expect(find.byKey(DASChronograph.punctualityTextKey), findsNothing);
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText(l10n.w_advised_speed_end));
    // Punctuality Visible
    expect(find.byKey(DASChronograph.punctualityTextKey), findsOne);

    // 4th advised speed Message (vmax, speed not in advised speed notification)
    // end is never displayed since goes directly to next segment
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText('A312'));
    expect(_findAdvisedSpeedNotificationContainingText('80'), findsNothing);

    // 5th advised speed Message (check service point & cancel)
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText('Lausanne'));
    await waitUntilExists(tester, _findAdvisedSpeedNotificationContainingText(l10n.w_advised_speed_cancel));

    // Check that cancel message disappears after some time
    await waitUntilNotExists(tester, _findAdvisedSpeedNotificationContainingText(l10n.w_advised_speed_cancel));

    await disconnect(tester);
  });

  testWidgets('test advised speeds displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T24');

    // Check that first row displayed advised speed
    final advisedSpeedStartRow = findDASTableRowByText('A236');
    await waitUntilExists(tester, _findNonEmptyAdvisedSpeedCellOf(advisedSpeedStartRow));
    _findTextWithin(advisedSpeedStartRow, '80');

    // Check service points display advised speed
    final geneveRow = findDASTableRowByText('Genève');
    expect(_findNonEmptyAdvisedSpeedCellOf(geneveRow), findsOne);
    _findTextWithin(geneveRow, '80');

    await dragUntilTextInStickyHeader(tester, 'Coppet');

    // Check that advised speed end displayed calculated speed on signal row
    final advisedSpeedEndRow = findDASTableRowByText('A653');
    await waitUntilExists(tester, _findCalculatedSpeedCellOf(advisedSpeedEndRow, '100'));

    await waitUntilExists(
      tester,
      find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text('Rolle')),
      maxWaitSeconds: 30,
    );

    // Check that advisedSpeed end displayed calculated speed on signal row
    final advisedSpeedEndRowServicePoint = findDASTableRowByText('Morges');
    expect(_findCalculatedSpeedCellOf(advisedSpeedEndRowServicePoint, '110'), findsOne);

    await disconnect(tester);
  });
}

void _findTextWithin(Finder baseFinder, String s) {
  final speed = find.descendant(of: baseFinder, matching: find.text(s));
  expect(speed, findsOneWidget);
}

Finder _findAdvisedSpeedNotificationContainingText(String text) {
  return find.descendant(
    of: find.byKey(AdvisedSpeedNotification.advisedSpeedNotificationKey),
    matching: find.textContaining(text),
  );
}

Finder _findNonEmptyAdvisedSpeedCellOf(Finder baseFinder) {
  return find.descendant(
    of: baseFinder,
    matching: find.byKey(AdvisedSpeedCellBody.nonEmptyKey),
  );
}

Finder _findCalculatedSpeedCellOf(Finder baseFinder, String speed) {
  return find.descendant(
    of: baseFinder,
    matching: find.textContaining(speed),
  );
}
