import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test details for ASR in T2 with missing from, until and reason', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T2');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet
    final asrRow = findDASTableRowByText('km 64.200 - km 47.200');
    await tapElement(tester, asrRow, warnIfMissed: false);
    _checkModalSheetContent(
      restrictionCount: 1,
      kmText: '64.200 - 47.200',
      vmaxText: '60',
    );

    // close modal sheet
    await _closeModalSheet(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test details for ASR in T3 with all details', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T3');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet
    final asrRow = findDASTableRowByText('km 64.200 - km 63.200');
    await tapElement(tester, asrRow, warnIfMissed: false);
    _checkModalSheetContent(
      restrictionCount: 1,
      kmText: '64.200 - 63.200',
      vmaxText: '60',
      fromText: '01.01.2022 00:01',
      untilText: '01.01.2060 00:01',
      reasonText: 'Schutz Personal',
    );

    // close modal sheet
    await _closeModalSheet(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
}

void _checkModalSheetContent({
  required String kmText,
  required int restrictionCount,
  String? vmaxText,
  String? fromText,
  String? untilText,
  String? reasonText,
}) {
  final modalSheet = find.byKey(DasModalSheet.modalSheetExtendedKey);
  expect(modalSheet, findsOneWidget);

  // check header
  final label = l10n.w_additional_speed_restriction_modal_title;
  final headerTitle = find.descendant(of: modalSheet, matching: find.text(label));
  expect(headerTitle, findsOneWidget);
  final countLabel = l10n.w_additional_speed_restriction_modal_subtitle_count;
  final headerCount = find.descendant(of: modalSheet, matching: find.text('$countLabel: $restrictionCount'));
  expect(headerCount, findsOneWidget);

  // check details table labels
  final kmLabel = l10n.w_additional_speed_restriction_modal_table_label_km;
  expect(find.descendant(of: modalSheet, matching: find.text(kmLabel)), findsOneWidget);
  final vmaxLabel = l10n.w_additional_speed_restriction_modal_table_label_vmax;
  expect(find.descendant(of: modalSheet, matching: find.text(vmaxLabel)), findsOneWidget);
  final fromLabel = l10n.w_additional_speed_restriction_modal_table_label_from;
  expect(find.descendant(of: modalSheet, matching: find.text(fromLabel)), findsOneWidget);
  final untilLabel = l10n.w_additional_speed_restriction_modal_table_label_until;
  expect(find.descendant(of: modalSheet, matching: find.text(untilLabel)), findsOneWidget);
  final reasonLabel = l10n.w_additional_speed_restriction_modal_table_label_reason;
  expect(find.descendant(of: modalSheet, matching: find.text(reasonLabel)), findsOneWidget);

  // check details table values
  expect(find.descendant(of: modalSheet, matching: find.text(kmText)), findsOneWidget);

  var nullableCount = 0;
  if (vmaxText != null) {
    expect(find.descendant(of: modalSheet, matching: find.text(vmaxText)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (fromText != null) {
    expect(find.descendant(of: modalSheet, matching: find.text(fromText)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (untilText != null) {
    expect(find.descendant(of: modalSheet, matching: find.text(untilText)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (reasonText != null) {
    expect(find.descendant(of: modalSheet, matching: find.text(reasonText)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (nullableCount > 0) {
    expect(find.descendant(of: modalSheet, matching: find.text('-')), findsExactly(nullableCount));
  }
}

Future<void> _closeModalSheet(WidgetTester tester) =>
    tapElement(tester, find.byKey(DasModalSheet.modalSheetCloseButtonKey));
