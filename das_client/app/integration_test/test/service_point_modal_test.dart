import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_table/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/detail_tab_communication.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/detail_tab_graduated_speeds.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/detail_tab_local_regulations.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/local_regulation_html_view.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/journey_table/widgets/header/header.dart';
import 'package:app/pages/journey/journey_table/widgets/header/header_icon_button.dart';
import 'package:app/pages/journey/journey_table/widgets/header/start_pause_button.dart';
import 'package:app/util/time_constants.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('general service point modal sheet tests', () {
    testWidgets('test displayed columns on open service point modal', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      final kilometreLabel = l10n.p_journey_table_kilometre_label;
      final timeLabel = l10n.p_journey_table_time_label_planned;

      // columns should be visible when modal is closed
      expect(findDASTableColumnByText(kilometreLabel), findsOne);
      expect(findDASTableColumnByText(timeLabel), findsOne);

      // open service point modal
      await _openByTapOnCellWithText(tester, 'Olten');

      // kilometre column should be hidden
      expect(findDASTableColumnByText(kilometreLabel), findsNothing);
      expect(findDASTableColumnByText(timeLabel), findsOne);

      await disconnect(tester);
    });
    testWidgets('test interaction points for modal sheet', (tester) async {
      // TODO: Workaround till SegmentedButton is fixed in Design System: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/issues/312
      FlutterError.onError = ignoreOverflowErrors;

      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      // open and check modal sheet over radio channel tap in header
      await _openRadioChannelByHeaderTap(tester);
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      // close modal sheet
      await _closeModalSheet(tester);
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      // check non-clickable graduated speeds if no details present
      await _openByTapOnGraduatedSpeedOf(tester, 'Burgdorf');
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      // open and check modal sheet with tap on graduated speeds
      await _openByTapOnCellWithText(tester, '75-70-60');
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

      // test tap on service point name without closing modal sheet
      await _openByTapOnCellWithText(tester, 'Olten');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Olten');

      await disconnect(tester);
    });
    testWidgets('test header button collapsed if detail model sheet open', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      expect(find.byKey(HeaderIconButton.headerIconWithLabelButtonKey), findsExactly(2));

      // open modal sheet and check if only icon buttons are shown
      await _openRadioChannelByHeaderTap(tester);
      expect(find.byKey(DasModalSheet.modalSheetExpandedKey), findsOneWidget);
      expect(find.byKey(HeaderIconButton.headerIconButtonKey), findsExactly(2));

      // check labeled buttons after close
      await _closeModalSheet(tester);
      expect(find.byKey(HeaderIconButton.headerIconWithLabelButtonKey), findsExactly(2));

      await disconnect(tester);
    });
    testWidgets('test only tabs are displayed with data', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      await _openByTapOnCellWithText(tester, 'Bern');
      await _checkModalSheetTabs(tester, [
        ServicePointModalTab.communication, // always displayed
        ServicePointModalTab.graduatedSpeeds,
      ]);

      await _openByTapOnCellWithText(tester, 'Burgdorf');
      await _checkModalSheetTabs(tester, [
        ServicePointModalTab.communication, // always displayed
      ]);

      await disconnect(tester);
    });
    testWidgets('test change of service point modal page with segmented button', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      // open modal with tap on service point name
      await _openByTapOnCellWithText(tester, 'Bern');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      // change tab to graduated speeds
      await _selectTab(tester, ServicePointModalTab.graduatedSpeeds);
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

      // change back to tab radio channels
      await _selectTab(tester, ServicePointModalTab.communication);
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      await disconnect(tester);
    });
    testWidgets('test modal closes after timeout without touch on screen', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T8');

      // open modal sheet with tap on service point name
      await _openByTapOnCellWithText(tester, 'Bern');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      final waitTime = DI.get<TimeConstants>().modalSheetAutomaticCloseAfterSeconds + 1;

      // wait until waitTime reached
      await Future.delayed(Duration(seconds: waitTime));
      await tester.pumpAndSettle();

      // check if modal sheet is closed
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      await disconnect(tester);
    });
    testWidgets('test modal sheet does close after timeout with automatic advancement paused', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T8');

      // open modal sheet with tap on service point name
      await _openByTapOnCellWithText(tester, 'Bern');
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Bern');

      // pause automatic advancement
      final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
      expect(pauseButton, findsOneWidget);
      await tapElement(tester, pauseButton);

      final waitTime = DI.get<TimeConstants>().modalSheetAutomaticCloseAfterSeconds + 1;

      // wait until waitTime reached
      await Future.delayed(Duration(seconds: waitTime));
      await tester.pumpAndSettle();

      // check if modal sheet is closed
      expect(find.byKey(DasModalSheet.modalSheetClosedKey), findsOneWidget);

      await disconnect(tester);
    });
  });

  group('graduated speed tab tests', () {
    testWidgets('test graduated speed info details', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      final tableRowBern = findDASTableRowByText('75-70-60');
      final indicator = find.descendant(of: tableRowBern, matching: find.byKey(DotIndicator.indicatorKey));
      expect(indicator, findsOneWidget);

      // open and check modal sheet with tap on graduated speeds
      await _openByTapOnCellWithText(tester, '75-70-60');
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Bern');

      expect(find.text('75-70-60'), findsExactly(3));

      expect(find.text('Zusatzinformation A'), findsOneWidget);

      await selectBreakSeries(tester, breakSeries: 'N50');

      expect(find.text('Zusatzinformation A'), findsNothing);
      expect(find.text('Zusatzinformation B'), findsOne);
      expect(find.text('70'), findsExactly(3));
      expect(find.text('60'), findsExactly(3));

      await disconnect(tester);
    });
  });

  group('communication tab tests', () {
    testWidgets('test communication network and radio channels displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T12M');

      // check communication information for Bern
      await _openByTapOnCellWithText(tester, 'Bern');
      final tabContentBern = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentBern, findsOneWidget);
      final gsmPIcon = find.descendant(of: tabContentBern, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPIcon, findsNothing);
      final gsmRIcon = find.descendant(of: tabContentBern, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmRIcon, findsNothing);
      final notFoundText = find.descendant(
        of: tabContentBern,
        matching: find.text(l10n.w_service_point_modal_communication_radio_channels_not_found),
      );
      expect(notFoundText, findsOneWidget);

      // Tab on Wankdorf -> GSM-P, 1407
      await _openByTapOnCellWithText(tester, 'Wankdorf');
      final tabContentWankdorf = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentWankdorf, findsOneWidget);
      final gsmPIconWankdorf = find.descendant(
        of: tabContentWankdorf,
        matching: find.byKey(CommunicationNetworkIcon.gsmPKey),
      );
      expect(gsmPIconWankdorf, findsOneWidget);
      final radioChannelsListWankdorf = find.descendant(
        of: tabContentBern,
        matching: find.byKey(DetailTabCommunication.radioChannelListKey),
      );
      expect(radioChannelsListWankdorf, findsOneWidget);
      _expectText(radioChannelsListWankdorf, '1407');

      // Tab on Olten -> GSM-R, 1102, 1103, 1104, 1105
      await _openByTapOnCellWithText(tester, 'Olten');
      final tabContentOlten = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContentOlten, findsOneWidget);
      final gsmRIconOlten = find.descendant(
        of: tabContentOlten,
        matching: find.byKey(CommunicationNetworkIcon.gsmRKey),
      );
      expect(gsmRIconOlten, findsOneWidget);
      final radioChannelsListOlten = find.descendant(
        of: tabContentOlten,
        matching: find.byKey(DetailTabCommunication.radioChannelListKey),
      );
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
      await loadJourney(tester, trainNumber: '1513M');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Lenzburg'), scrollableFinder, const Offset(0, -50));

      // open graduated speed tab of Rupperswil
      await _openByTapOnGraduatedSpeedOf(tester, 'Rupperswil');
      _checkOpenModalSheet(DetailTabGraduatedSpeeds.graduatedSpeedsTabKey, 'Rupperswil');

      // change to communication tab and check content
      await _selectTab(tester, ServicePointModalTab.communication);
      final tabContent = find.byKey(DetailTabCommunication.communicationTabKey);
      expect(tabContent, findsOneWidget);
      final gsmRIcon = find.descendant(of: tabContent, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(gsmRIcon, findsOneWidget);
      final radioChannels = find.descendant(
        of: tabContent,
        matching: find.byKey(DetailTabCommunication.radioChannelListKey),
      );
      expect(radioChannels, findsOneWidget);
      _expectText(radioChannels, '1308');

      await disconnect(tester);
    });

    testWidgets('test SIM corridor information', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T20M');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check Reichenbach im Kandertal SIM information
      await _openByTapOnCellWithText(tester, 'Reichenbach im Kandertal');
      expect(find.byKey(DetailTabCommunication.simCorridorListKey), findsNothing);

      // scroll down so that if Frutigen is in the stickyFooter it can be seen as a single row
      final secondBlockSignal = find.text('P112');
      await tester.drag(secondBlockSignal, const Offset(0, -100));
      await tester.pumpAndSettle();

      // check Frutigen for SIM information
      final frutigenRow = find.text('Frutigen');
      expect(frutigenRow, findsOneWidget);
      await tester.tap(frutigenRow);
      await tester.pumpAndSettle();
      expect(find.byKey(DetailTabCommunication.simCorridorListKey), findsOneWidget);
      expect(find.text('Frutigen - Kandergrund'), findsOneWidget);

      // check Domodossola FM SIM information
      await tester.dragUntilVisible(find.text('Domodossola FM'), scrollableFinder, const Offset(0, -50));
      await tester.pumpAndSettle();

      await _openByTapOnCellWithText(tester, 'Domodossola FM');
      expect(find.byKey(DetailTabCommunication.simCorridorListKey), findsOneWidget);
      expect(find.text('1392'), findsOneWidget);
      expect(find.text('Domodossola - Preglia, linkes Gleis'), findsOneWidget);
      expect(find.text('1393'), findsOneWidget);
      expect(find.text('Domodossola - Preglia, rechtes Gleis'), findsOneWidget);

      // check Footnote header
      expect(find.text(l10n.c_radn_sim), findsAny);

      await disconnect(tester);
    });
  });

  group('local regulation tab tests', () {
    testWidgets('test local regulation tab is shown', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T25');
      final scrollableFinder = find.byType(AnimatedList);

      await _openByTapOnCellWithText(tester, 'Olten');
      await _checkModalSheetTabs(tester, [
        ServicePointModalTab.communication, // always displayed
        ServicePointModalTab.localRegulations,
      ]);

      await tester.dragUntilVisible(find.text('A604'), scrollableFinder, const Offset(0, -50));
      await _openByTapOnCellWithText(tester, 'Dulliken');
      await _checkModalSheetTabs(tester, [
        ServicePointModalTab.communication, // always displayed
      ]);

      await disconnect(tester);
    });

    testWidgets('test tab change from local regulation', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T25');

      await _openByTapOnCellWithText(tester, 'Olten');

      // change tab to local regulations and check if full width
      await _selectTab(tester, ServicePointModalTab.localRegulations);
      _checkOpenModalSheet(DetailTabLocalRegulations.localRegulationsTabKey, 'Olten', isMaximized: true);

      // change back to tab radio channels
      await _selectTab(tester, ServicePointModalTab.communication);
      _checkOpenModalSheet(DetailTabCommunication.communicationTabKey, 'Olten');

      await disconnect(tester);
    });

    testWidgets('test local regulation webview is shown', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T25');

      await _openByTapOnCellWithText(tester, 'Olten');

      // change tab to local regulations and check if web view is loaded
      await _selectTab(tester, ServicePointModalTab.localRegulations);
      _checkOpenModalSheet(DetailTabLocalRegulations.localRegulationsTabKey, 'Olten', isMaximized: true);
      await waitUntilNotExists(tester, find.byKey(LocalRegulationHtmlView.webViewKey), maxWaitSeconds: 5);

      await disconnect(tester);
    });
  });

  testWidgets('test short signal names are displayed when modal is open', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T9999M');

    expect(find.text(l10n.c_main_signal_function_entry), findsAny);

    final scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(find.text(l10n.c_main_signal_function_exit), scrollableFinder, const Offset(0, -50));
    await tester.pumpAndSettle();

    expect(find.text(l10n.c_main_signal_function_exit), findsAny);
    expect(find.text(l10n.c_main_signal_function_entry_short), findsNothing);
    expect(find.text(l10n.c_main_signal_function_exit_short), findsNothing);

    await tester.dragUntilVisible(findDASTableRowByText('(Bahnhof A)'), scrollableFinder, const Offset(0, 50));
    await tester.pumpAndSettle();

    await _openByTapOnCellWithText(tester, '(Bahnhof A)');
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text(l10n.c_main_signal_function_entry_short),
      scrollableFinder,
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.c_main_signal_function_entry), findsNothing);
    expect(find.text(l10n.c_main_signal_function_exit), findsNothing);
    expect(find.text(l10n.c_main_signal_function_entry_short), findsAny);
    expect(find.text(l10n.c_main_signal_function_exit_short), findsAny);

    await disconnect(tester);
  });

  testWidgets('test departure authorization are displayed in modal', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T31M');

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    await _openAndCheckDepartureAuth(tester, 'Dietikon', '*');
    await _openAndCheckDepartureAuth(tester, 'Glanzenberg', 'sms 3-6');

    await _openByTapOnCellWithText(tester, 'Schlieren');
    expect(find.byKey(DetailTabCommunication.departureAuthorizationKey), findsNothing);

    await tester.dragUntilVisible(find.text('Zürich Hardbrücke'), scrollableFinder, const Offset(0, -50));
    await tester.pumpAndSettle();

    await _openAndCheckDepartureAuth(tester, 'Zürich Altstetten', 'sms 2-4 6,7');

    await _openByTapOnCellWithText(tester, 'Zürich Hardbrücke');
    expect(find.byKey(DetailTabCommunication.departureAuthorizationKey), findsNothing);

    await disconnect(tester);
  });
}

Future<void> _openAndCheckDepartureAuth(WidgetTester tester, String servicePoint, String departureAuthText) async {
  await _openByTapOnCellWithText(tester, servicePoint);
  final departureAuth = find.byKey(DetailTabCommunication.departureAuthorizationKey);
  expect(departureAuth, findsOne);
  expect(find.descendant(of: departureAuth, matching: find.text(departureAuthText)), findsOne);
}

Future<void> _openByTapOnGraduatedSpeedOf(WidgetTester tester, String text) async {
  final tableRow = findDASTableRowByText(text);
  final speedCell = find.descendant(
    of: tableRow,
    matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
  );
  await tapElement(tester, speedCell.first, warnIfMissed: false);
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
  final tableRow = findDASTableRowByText(cellText);
  final cell = find.descendant(of: tableRow, matching: find.text(cellText));
  await tapElement(tester, cell, warnIfMissed: false);
}

Future<void> _selectTab(WidgetTester tester, ServicePointModalTab tab) async {
  final segmentedButton = find.byKey(ServicePointModalBuilder.segmentedButtonKey);
  final segment = find.descendant(of: segmentedButton, matching: find.byIcon(tab.icon));
  await tapElement(tester, segment, warnIfMissed: false);
}

void _checkOpenModalSheet(Key tabContentKey, String servicePointName, {bool isMaximized = false}) {
  final modalSheetStateKey = isMaximized ? DasModalSheet.modalSheetMaximizedKey : DasModalSheet.modalSheetExpandedKey;
  final modalSheetState = find.byKey(modalSheetStateKey);
  expect(modalSheetState, findsOneWidget);

  final modalSheet = find.byKey(DasModalSheet.modalSheetKey);
  final tabContent = find.descendant(of: modalSheet, matching: find.byKey(tabContentKey));
  expect(tabContent, findsOneWidget);
  final servicePointLabel = find.descendant(of: modalSheet, matching: find.text(servicePointName));
  expect(servicePointLabel, findsOneWidget);
}

Future<void> _checkModalSheetTabs(WidgetTester tester, List<ServicePointModalTab> displayedTabs) async {
  await tester.pumpAndSettle();
  final modalSheet = find.byKey(DasModalSheet.modalSheetKey);
  for (final tab in displayedTabs) {
    final tabIcon = find.descendant(of: modalSheet, matching: find.byIcon(tab.icon));
    expect(tabIcon, findsOneWidget);
  }

  // check if other tabs are not shown
  final notShownTabs = ServicePointModalTab.values.where((tab) => !displayedTabs.contains(tab));
  for (final tab in notShownTabs) {
    final tabIcon = find.descendant(of: modalSheet, matching: find.byIcon(tab.icon));
    expect(tabIcon, findsNothing);
  }
}

Future<void> _closeModalSheet(WidgetTester tester) =>
    tapElement(tester, find.byKey(DasModalSheet.modalSheetCloseButtonKey));
