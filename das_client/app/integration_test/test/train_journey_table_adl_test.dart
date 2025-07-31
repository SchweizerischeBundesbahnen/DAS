import 'package:app/pages/journey/train_journey/widgets/header/das_chronograph.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/adl_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/advised_speed_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/calculated_speed_cell_body.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test adl notification displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T24');

    // Check that there is no ADL notification
    expect(find.byKey(ADLNotification.adlNotificationKey), findsNothing);

    // 1st ADL Message (check speed)
    await waitUntilExists(tester, _findAdlNotificationContainingText('80'));
    await waitUntilExists(tester, _findAdlNotificationContainingText(l10n.w_adl_end));

    // 2nd ADL Message (check signal)
    await waitUntilExists(tester, _findAdlNotificationContainingText('A653'));
    // Punctuality Hidden
    expect(find.byKey(DASChronograph.punctualityTextKey), findsNothing);
    await waitUntilExists(tester, _findAdlNotificationContainingText(l10n.w_adl_end));
    // Punctuality Visible
    expect(find.byKey(DASChronograph.punctualityTextKey), findsOne);

    // 3rd ADL Message (check icon)
    await waitUntilExists(tester, find.byKey(ADLNotification.adlNotificationIconKey));
    await waitUntilExists(tester, _findAdlNotificationContainingText(l10n.w_adl_end));

    // 4th ADL Message (vmax, speed not in adl)
    await waitUntilExists(tester, _findAdlNotificationContainingText('A312'));
    expect(_findAdlNotificationContainingText('80'), findsNothing);
    await waitUntilExists(tester, _findAdlNotificationContainingText(l10n.w_adl_end));

    // 5th ADL Message (check service point & cancel)
    await waitUntilExists(tester, _findAdlNotificationContainingText('Allaman'));
    await waitUntilExists(tester, _findAdlNotificationContainingText(l10n.w_adl_cancel));

    // Check that cancel message disappears after some time
    await waitUntilNotExists(tester, _findAdlNotificationContainingText(l10n.w_adl_cancel));

    await disconnect(tester);
  });

  testWidgets('test advised speeds displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T24M');

    // Check that first row displayed advised speed
    final adlStartRow = findDASTableRowByText('A236');
    expect(_findNonEmptyAdvisedSpeedCellOf(adlStartRow), findsOne);
    _findTextWithin(adlStartRow, '80');

    // Check service points display advised speed
    final geneveRow = findDASTableRowByText('Genève');
    expect(_findNonEmptyAdvisedSpeedCellOf(geneveRow), findsOne);
    _findTextWithin(geneveRow, '80');

    await dragUntilTextInStickyHeader(tester, 'Coppet');

    // Check that adl end displayed calculated speed on signal row
    final adlEndRow = findDASTableRowByText('A653');
    expect(_findNonEmptyCalculatedSpeedCellOf(adlEndRow), findsOne);
    _findTextWithin(adlEndRow, '110');

    await dragUntilTextInStickyHeader(tester, 'Allaman');

    // Check that adl end displayed calculated speed on signal row
    final adlEndRowServicePoint = findDASTableRowByText('Allaman');
    expect(_findNonEmptyCalculatedSpeedCellOf(adlEndRowServicePoint), findsOne);
    _findTextWithin(adlEndRowServicePoint, '100');

    await disconnect(tester);
  });
}

void _findTextWithin(Finder baseFinder, String s) {
  final speed = find.descendant(of: baseFinder, matching: find.text(s));
  expect(speed, findsOneWidget);
}

Finder _findAdlNotificationContainingText(String text) {
  return find.descendant(
    of: find.byKey(ADLNotification.adlNotificationKey),
    matching: find.textContaining(text),
  );
}

Finder _findNonEmptyAdvisedSpeedCellOf(Finder baseFinder) {
  return find.descendant(
    of: baseFinder,
    matching: find.byKey(AdvisedSpeedCellBody.nonEmptyKey),
  );
}

Finder _findNonEmptyCalculatedSpeedCellOf(Finder baseFinder) {
  return find.descendant(
    of: baseFinder,
    matching: find.byKey(CalculatedSpeedCellBody.nonEmptyKey),
  );
}
