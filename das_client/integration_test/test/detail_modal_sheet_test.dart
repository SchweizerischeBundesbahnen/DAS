import 'package:das_client/app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_communication.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_graduated_speeds.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_local_regulations.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/animated_header_icon_button.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:das_client/app/widgets/indicator_wrapper.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('general modal sheet tests', () {
    testWidgets('test interaction points for detail modal sheet', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T8');

      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      // open and check modal sheet over radio channel tap in header
      await _openRadioChannelByHeaderTap(tester);
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Burgdorf');

      // close modal sheet
      await _closeModalSheet(tester);
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      // open and check modal sheet with tap on graduated speeds
      await _openByTapOnCellWithText(tester, '75-70-60');
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

      // test tap on service point name without closing modal sheet
      await _openByTapOnCellWithText(tester, 'Olten');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Olten');

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
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Olten');

      // change tab to graduated speeds
      await _selectTab(tester, DetailModalSheetTab.graduatedSpeeds);
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Olten');

      // change tab to local regulations and check if full width
      await _selectTab(tester, DetailModalSheetTab.localRegulations);
      _checkOpenModalSheet(DetailTabLocalRegulations.localRegulationsTabKey, 'Olten', isMaximized: true);

      // change back to tab radio channels
      await _selectTab(tester, DetailModalSheetTab.communication);
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Olten');

      await disconnect(tester);
    });
    testWidgets('test modal sheet closes after timeout without touch on screen', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T8');

      // open modal sheet with tap on service point name
      await _openByTapOnCellWithText(tester, 'Bern');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      // wait till 10s idle time have passed
      final timeout = DASModalSheetController.automaticCloseAfterSeconds + 1;
      await Future.delayed(Duration(seconds: timeout));
      await tester.pumpAndSettle();

      // check if modal sheet is closed
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      await disconnect(tester);
    });
    testWidgets('test modal sheet does close after timeout with automatic advancement paused', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T8');

      // open modal sheet with tap on service point name
      await _openByTapOnCellWithText(tester, 'Bern');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      // pause automatic advancement
      final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
      expect(pauseButton, findsOneWidget);
      await tapElement(tester, pauseButton);

      // wait till 10s idle time have passed
      final timeout = DASModalSheetController.automaticCloseAfterSeconds + 1;
      await Future.delayed(Duration(seconds: timeout));
      await tester.pumpAndSettle();

      // check if modal sheet is closed
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      await disconnect(tester);
    });
  });

  group('graduated speed tab tests', () {
    testWidgets('test graduated speed info details', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T8');

      final tableRowBern = findDASTableRowByText('75-70-60');
      final indicator = find.descendant(of: tableRowBern, matching: find.byKey(IndicatorWrapper.indicatorKey));
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
  });

  group('communication tab tests', () {
    testWidgets('test communication network and radio channels displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: 'T12');
      await pauseAutomaticAdvancement(tester);

      // check communication information for Bern
      await _openByTapOnCellWithText(tester, 'Bern');
      final tabContentBern = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentBern, findsOneWidget);
      final gsmPIcon = find.descendant(of: tabContentBern, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPIcon, findsNothing);
      final gsmRIcon = find.descendant(of: tabContentBern, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmRIcon, findsNothing);
      final notFoundText = find.descendant(
          of: tabContentBern, matching: find.text(l10n.w_detail_modal_sheet_communication_radio_channels_not_found));
      expect(notFoundText, findsOneWidget);

      // Tab on Wankdorf -> GSM-P, 1407
      await _openByTapOnCellWithText(tester, 'Wankdorf');
      final tabContentWankdorf = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentWankdorf, findsOneWidget);
      final gsmPIconWankdorf =
          find.descendant(of: tabContentWankdorf, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPIconWankdorf, findsOneWidget);
      final radioChannelsListWankdorf =
          find.descendant(of: tabContentBern, matching: find.byKey(DetailTabCommunication.radioChannelListKey));
      expect(radioChannelsListWankdorf, findsOneWidget);
      _expectText(radioChannelsListWankdorf, '1407');

      // Tab on Olten -> GSM-R, 1102, 1103, 1104, 1105
      await _openByTapOnCellWithText(tester, 'Olten');
      final tabContentOlten = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentOlten, findsOneWidget);
      final gsmRIconOlten =
          find.descendant(of: tabContentOlten, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(gsmRIconOlten, findsOneWidget);
      final radioChannelsListOlten =
          find.descendant(of: tabContentOlten, matching: find.byKey(DetailTabCommunication.radioChannelListKey));
      expect(radioChannelsListOlten, findsOneWidget);
      _expectText(radioChannelsListOlten, '1102');
      _expectText(radioChannelsListOlten, 'Richtung Süd: Fahrdienstleiter');
      _expectText(radioChannelsListOlten, '1103');
      _expectText(radioChannelsListOlten, 'Richtung Nord: Fahrdienstleiter');
      _expectText(radioChannelsListOlten, '1104');
      _expectText(radioChannelsListOlten, 'Rangierbahnhof: Fahrdienstleiter Stellwerk 3');
      _expectText(radioChannelsListOlten, '1105');

      await disconnect(tester);
    });
    testWidgets('test communication information present when opening from other tab', (tester) async {
      await prepareAndStartApp(tester);
      await loadTrainJourney(tester, trainNumber: '1513');
      await pauseAutomaticAdvancement(tester);

      // open graduated speed tab of Olten
      await _openByTapOnCellWithText(tester, '90');
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Olten');

      // change to communication tab and check content
      await _selectTab(tester, DetailModalSheetTab.communication);
      final tabContent = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContent, findsOneWidget);
      final gsmRIcon = find.descendant(of: tabContent, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(gsmRIcon, findsOneWidget);
      final radioChannels =
          find.descendant(of: tabContent, matching: find.byKey(DetailTabCommunication.radioChannelListKey));
      expect(radioChannels, findsOneWidget);
      _expectText(radioChannels, '1304', count: 2);
      _expectText(radioChannels, 'Richtung Süd: Fahrdienstleiter');
      _expectText(radioChannels, '1302');
      _expectText(radioChannels, 'Richtung Nord: Fahrdienstleiter');
      _expectText(radioChannels, 'Rangierbahnhof: Fahrdienstleiter Stellwerk 3');
      _expectText(radioChannels, '1310');

      await disconnect(tester);
    });
  });
}

void _expectText(Finder finder, String text, {int count = 1}) {
  final textWidget = find.descendant(of: finder, matching: find.text(text));
  expect(textWidget, findsExactly(count));
}

Future<void> _openRadioChannelByHeaderTap(WidgetTester tester) async {
  final gsmIcon = find.descendant(of: find.byType(Header), matching: find.byIcon(SBBIcons.telephone_gsm_small));
  await tapElement(tester, gsmIcon, warnIfMissed: false);
}

Future<void> _openByTapOnCellWithText(WidgetTester tester, String cellText) async {
  final tableRowBern = findDASTableRowByText(cellText);
  final cell = find.descendant(of: tableRowBern, matching: find.text(cellText));
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
