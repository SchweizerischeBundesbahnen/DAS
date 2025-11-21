import 'package:app/pages/journey/journey_table/widgets/detail_modal/additional_speed_restriction_modal/details_table.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test displayed columns on open ASR modal', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T2');

    final kilometreLabel = l10n.p_journey_table_kilometre_label;
    final timeLabel = l10n.p_journey_table_time_label_planned;

    // columns should be visible when modal is closed
    expect(findDASTableColumnByText(kilometreLabel), findsOne);
    expect(findDASTableColumnByText(timeLabel), findsOne);

    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');

    // time column should be hidden
    expect(findDASTableColumnByText(kilometreLabel), findsOne);
    expect(findDASTableColumnByText(timeLabel), findsNothing);

    await disconnect(tester);
  });
  testWidgets('test details for ASR in T2 with missing from, until and reason', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T2');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet
    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');
    _checkModalSheetContent(
      testData: [
        _ASRTestData(kmText: '64.200 - 47.200', vmaxText: '60'),
      ],
    );

    // close modal sheet
    await _closeModalSheet(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test details for ASR in T3 with all details', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T3');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet
    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 63.200');
    _checkModalSheetContent(
      testData: [
        _ASRTestData(
          kmText: '64.200 - 63.200',
          vmaxText: '60',
          fromText: '01.01.2022 00:00',
          untilText: '01.01.2060 00:00',
          reasonText: 'Schutz Personal',
        ),
      ],
    );

    // close modal sheet
    await _closeModalSheet(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test details for complex ASR in T18', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T18');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // scroll to complex ASR
    final scrollableFinder = find.byType(AnimatedList);
    final rowFinder = find.descendant(of: scrollableFinder, matching: find.text('WANZ'));
    await tester.dragUntilVisible(rowFinder, scrollableFinder, const Offset(0, -100));

    // open and check modal sheet
    await _openASRModalByTapOnRow(tester, 'km 83.100 - km 6.600');
    _checkModalSheetContent(
      testData: [
        _ASRTestData(
          kmText: '83.100 - 6.600',
          vmaxText: '50',
          reasonText: 'Schutz Personal',
        ),
        _ASRTestData(
          kmText: '47.200 - 12.000',
          vmaxText: '60',
          reasonText: 'Umbau',
        ),
      ],
    );

    await disconnect(tester);
  });
}

Future<void> _openASRModalByTapOnRow(WidgetTester tester, String text) async {
  final asrRow = findDASTableRowByText(text);
  await tapElement(tester, asrRow, warnIfMissed: false);
}

void _checkModalSheetContent({required List<_ASRTestData> testData}) {
  final modalSheet = find.byKey(DasModalSheet.modalSheetKey);
  expect(modalSheet, findsOneWidget);

  // check header
  final label = l10n.w_additional_speed_restriction_modal_title;
  final headerTitle = find.descendant(of: modalSheet, matching: find.text(label));
  expect(headerTitle, findsOneWidget);
  final countLabel = l10n.w_additional_speed_restriction_modal_subtitle_count;
  final headerCount = find.descendant(of: modalSheet, matching: find.text('$countLabel: ${testData.length}'));
  expect(headerCount, findsOneWidget);

  // check details table labels
  final detailTables = find.descendant(of: modalSheet, matching: find.byKey(DetailsTable.detailsTableKey));
  expect(detailTables, findsExactly(testData.length));
  testData.forEachIndexed((index, data) {
    _checkDetailsTable(detailTables.at(index), data);
  });
}

void _checkDetailsTable(Finder detailsTable, _ASRTestData asr) {
  final kmLabel = l10n.w_additional_speed_restriction_modal_table_label_km;
  expect(find.descendant(of: detailsTable, matching: find.text(kmLabel)), findsOneWidget);
  final vmaxLabel = l10n.w_additional_speed_restriction_modal_table_label_vmax;
  expect(find.descendant(of: detailsTable, matching: find.text(vmaxLabel)), findsOneWidget);
  final fromLabel = l10n.w_additional_speed_restriction_modal_table_label_from;
  expect(find.descendant(of: detailsTable, matching: find.text(fromLabel)), findsOneWidget);
  final untilLabel = l10n.w_additional_speed_restriction_modal_table_label_until;
  expect(find.descendant(of: detailsTable, matching: find.text(untilLabel)), findsOneWidget);
  final reasonLabel = l10n.w_additional_speed_restriction_modal_table_label_reason;
  expect(find.descendant(of: detailsTable, matching: find.text(reasonLabel)), findsOneWidget);

  // check details table values
  expect(find.descendant(of: detailsTable, matching: find.text(asr.kmText)), findsOneWidget);

  var nullableCount = 0;
  if (asr.vmaxText != null) {
    expect(find.descendant(of: detailsTable, matching: find.text(asr.vmaxText!)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (asr.fromText != null) {
    expect(find.descendant(of: detailsTable, matching: find.text(asr.fromText!)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (asr.untilText != null) {
    expect(find.descendant(of: detailsTable, matching: find.text(asr.untilText!)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (asr.reasonText != null) {
    expect(find.descendant(of: detailsTable, matching: find.text(asr.reasonText!)), findsOneWidget);
  } else {
    nullableCount += 1;
  }

  if (nullableCount > 0) {
    expect(find.descendant(of: detailsTable, matching: find.text('-')), findsExactly(nullableCount));
  }
}

class _ASRTestData {
  _ASRTestData({
    required this.kmText,
    this.vmaxText,
    this.fromText,
    this.untilText,
    this.reasonText,
  });

  final String kmText;
  String? vmaxText;
  String? fromText;
  String? untilText;
  String? reasonText;
}

Future<void> _closeModalSheet(WidgetTester tester) =>
    tapElement(tester, find.byKey(DasModalSheet.modalSheetCloseButtonKey));
