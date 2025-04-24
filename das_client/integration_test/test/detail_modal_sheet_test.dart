import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_graduated_speeds.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_local_regulations.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_radio_channels.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/animated_header_icon_button.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test interaction points for detail modal sheet', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T8');

    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet over radio channel tap in header
    await _openRadioChannelByHeaderTap(tester);
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Burgdorf');

    // close modal sheet
    await _closeModalSheet(tester);
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    // open and check modal sheet with tap on graduated speeds
    await _openByTapOnCellWithText(tester, '75-70-60');
    _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

    // test tap on service point name without closing modal sheet
    await _openByTapOnCellWithText(tester, 'Olten');
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Olten');

    await disconnect(tester);
  });
  testWidgets('test header button collapsed on if detail model sheet open', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T9999');

    expect(find.byKey(AnimatedHeaderIconButton.headerIconWithLabelButtonKey), findsExactly(2));

    // open modal sheet and check if only icon buttons are shown
    await _openRadioChannelByHeaderTap(tester);
    expect(find.byKey(DasModalSheet.modalSheetExtendedKey), findsOneWidget);
    expect(find.byKey(AnimatedHeaderIconButton.headerIconButtonKey), findsExactly(2));

    // check labeled buttons after close
    await _closeModalSheet(tester);
    expect(find.byKey(AnimatedHeaderIconButton.headerIconWithLabelButtonKey), findsExactly(2));

    await disconnect(tester);
  });
  testWidgets('test change of detail modal sheet page with segmented button', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T8');

    // open modal sheet with tap on service point name
    await _openByTapOnCellWithText(tester, 'Olten');
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Olten');

    // change tab to graduated speeds
    await _selectTab(tester, DetailModalSheetTab.graduatedSpeeds);
    _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Olten');

    // change tab to local regulations and check if full width
    await _selectTab(tester, DetailModalSheetTab.localRegulations);
    _checkOpenModalSheet(DetailTabLocalRegulations.localRegulationsTabKey, 'Olten', isMaximized: true);

    // change back to tab radio channels
    await _selectTab(tester, DetailModalSheetTab.radioChannels);
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Olten');

    await disconnect(tester);
  });
  testWidgets('test modal sheet closes after 10s without touch on screen', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T8');

    // open modal sheet with tap on service point name
    await _openByTapOnCellWithText(tester, 'Bern');
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Bern');

    // wait till 10s idle time have passed
    await Future.delayed(const Duration(seconds: 11));
    await tester.pumpAndSettle();

    // check if modal sheet is closed
    expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

    await disconnect(tester);
  });
  testWidgets('test modal sheet does not close after 10s with automatic advancement paused', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T8');

    // open modal sheet with tap on service point name
    await _openByTapOnCellWithText(tester, 'Bern');
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Bern');

    // pause automatic advancement
    final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
    expect(pauseButton, findsOneWidget);
    await tapElement(tester, pauseButton);

    // wait till 10s idle time have passed
    await Future.delayed(const Duration(seconds: 11));
    await tester.pumpAndSettle();

    // check if modal sheet is still open
    _checkOpenModalSheet(DetailTabRadioChannels.radioChannelsTabKey, 'Bern');

    await disconnect(tester);
  });

  testWidgets('test graduated speed info details', (tester) async {
    await prepareAndStartApp(tester);
    await loadTrainJourney(tester, trainNumber: 'T8');

    final tableRowBern = findDASTableRowByText('75-70-60');
    final indicator = find.descendant(of: tableRowBern, matching: find.byKey(GraduatedSpeedsCellBody.indicatorKey));
    expect(indicator, findsOneWidget);

    // open and check modal sheet with tap on graduated speeds
    await _openByTapOnCellWithText(tester, '75-70-60');
    _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

    expect(find.text('Zusatzinformation A'), findsOneWidget);

    await selectBreakSeries(tester, breakSeries: 'N50');

    expect(find.text('Zusatzinformation A'), findsNothing);
    expect(find.text('Zusatzinformation B'), findsOneWidget);

    await disconnect(tester);
  });
}

Future<void> _openRadioChannelByHeaderTap(WidgetTester tester) async {
  final gsmIcon = find.descendant(of: find.byType(Header), matching: find.byIcon(SBBIcons.telephone_gsm_small));
  await tapElement(tester, gsmIcon, warnIfMissed: false);
}

Future<void> _openByTapOnCellWithText(WidgetTester tester, String cellText) async {
  final tableRow = findDASTableRowByText(cellText);
  final cell = find.descendant(of: tableRow, matching: find.text(cellText));
  await tapElement(tester, cell, warnIfMissed: false);
}

Future<void> _selectTab(WidgetTester tester, DetailModalSheetTab tab) async {
  final segmentedButton = find.byKey(DetailModalSheet.segmentedButtonKey);
  final segment = find.descendant(of: segmentedButton, matching: find.byIcon(tab.icon));
  await tapElement(tester, segment, warnIfMissed: false);
}

void _checkOpenModalSheet(Key tabContentKey, String servicePointName, {bool isMaximized = false}) {
  final modalSheetKey = isMaximized ? DasModalSheet.modalSheetMaximizedKey : DasModalSheet.modalSheetExtendedKey;
  final modalSheet = find.byKey(modalSheetKey);
  expect(modalSheet, findsOneWidget);
  final tabContent = find.descendant(of: modalSheet, matching: find.byKey(tabContentKey));
  expect(tabContent, findsOneWidget);
  final servicePointLabel = find.descendant(of: modalSheet, matching: find.text(servicePointName));
  expect(servicePointLabel, findsOneWidget);
}

Future<void> _closeModalSheet(WidgetTester tester) =>
    tapElement(tester, find.byKey(DasModalSheet.modalSheetCloseButtonKey));
