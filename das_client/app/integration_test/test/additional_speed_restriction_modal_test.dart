import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/details_table.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/detail_tab_communication.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('asrModal_whenModalOpened_thenHidesTimeColumn|p7ydFbghPvgMoyaSfNjF|tests:1219', (tester) async {
    await IntegrationTestApp.start(tester);
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
  testWidgets('asrModal_whenMissingOptionalFields_thenShowsDashes|dJrbXirX37Dq6cvL1nLx|tests:567', (tester) async {
    await IntegrationTestApp.start(tester);
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
  testWidgets('asrModal_whenAllDetailsPresent_thenShowsAllDetails|0eQJ41IWn8ueyne4Nzh2|tests:567', (tester) async {
    await IntegrationTestApp.start(tester);
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
  testWidgets('asrModal_whenSameRowTappedTwice_thenClosesModal|pJoSYPI4xQRZFe8UsGTd|tests:1875', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T2');

    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    // tapping the element that opened the modal a second time closes it
    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('asrModal_whenRadioChannelTappedWhileOpen_thenSwitchesWithoutClosing|FYCL15anxOtsmYgvuzl3|tests:1875', (
    tester,
  ) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T2');

    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');
    _checkModalSheetContent(
      testData: [_ASRTestData(kmText: '64.200 - 47.200', vmaxText: '60')],
    );

    // tapping a different piece of information (radio channel of a service point) while the ASR
    // modal is open switches directly to the new content instead of closing first
    final gsmIcon = find.descendant(of: find.byType(Header), matching: find.byIcon(SBBIcons.telephone_gsm_small));
    await tapElement(tester, gsmIcon, warnIfMissed: false);

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);
    expect(find.byKey(DetailTabCommunication.communicationTabKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('asrModal_whenNonInteractiveAreaTapped_thenClosesModal|jajHl07W13dG4g0wsctj|tests:1875', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T2');

    await _openASRModalByTapOnRow(tester, 'km 64.200 - km 47.200');
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsNothing);

    // tapping a non-interactive area inside the modal (its title) closes it
    final modalSheet = find.byKey(DasModalSheet.modalSheetKey);
    final title = find.descendant(
      of: modalSheet,
      matching: find.text(l10n.w_additional_speed_restriction_modal_title),
    );
    await tapElement(tester, title, warnIfMissed: false);

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('asrModal_whenComplexAsrWithMultipleEntries_thenShowsAllEntries|4dhyrq0I6dm7WCcmpMDR|tests:227', (
    tester,
  ) async {
    await IntegrationTestApp.start(tester);
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
