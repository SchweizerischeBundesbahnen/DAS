import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:app/pages/journey/train_journey/widgets/header/das_chronograph.dart';
import 'package:app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:app/pages/journey/train_journey/widgets/header/radio_contact.dart';
import 'package:app/pages/journey/train_journey/widgets/header/sim_identifier.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/util/time_constants.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app_test.dart';
import '../mocks/mock_battery.dart';
import '../mocks/mock_brightness_manager.dart';
import '../util/test_utils.dart';

Future<void> main() async {
  group('train journey header test', () {
    patrolTest('test chronograph punctuality display hides when no updates come', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T4');

      final chronograph = find.byType(DASChronograph);
      expect(chronograph, findsOneWidget);

      // wait until delay displayed
      await waitUntilExists(
        tester.tester,
        find.descendant(of: chronograph, matching: find.byKey(DASChronograph.punctualityTextKey)),
      );

      final waitTime = DI.get<TimeConstants>().punctualityDisappearSeconds + 1;

      // wait until waitTime reached
      await tester.tester.pumpAndSettle(Duration(seconds: waitTime));

      // check that delay text has disappeared
      expect(find.descendant(of: chronograph, matching: find.byKey(DASChronograph.punctualityTextKey)), findsNothing);
    });

    patrolTest('test chronograph punctuality display becomes stale when no updates come', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T4');

      final chronograph = find.byType(DASChronograph);
      expect(chronograph, findsOneWidget);

      final context = tester.tester.element(chronograph);

      // wait until delay displayed
      await waitUntilExists(tester.tester, find.descendant(of: chronograph, matching: find.text('+00:40')));

      final waitTime = DI.get<TimeConstants>().punctualityStaleSeconds + 1;

      // wait until waitTime reached
      await tester.tester.pumpAndSettle(Duration(seconds: waitTime));

      // check that delay text is stale
      final delayTextWidget = tester.tester.widget<Text>(
        find.descendant(of: chronograph, matching: find.text('+00:40')),
      );
      expect(delayTextWidget.style?.color, ThemeUtil.getColor(context, SBBColors.graphite, SBBColors.granite));
    });

    patrolTest('test always-on display is turned on when journey is loaded', (tester) async {
      await prepareAndStartApp(tester.tester);

      // Get that the always-on display is turned off, because journey is not started yet
      bool currentDisplayTurnedOn = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOn, false);

      await loadTrainJourney(tester.tester, trainNumber: 'T4');

      // Get that the always-on display is turned on, because the journey is started
      currentDisplayTurnedOn = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOn, true);
    });

    patrolTest('test always-on display is turned off when journey is closed', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T4');

      // Get that the always-on display is turned on, because the journey is started
      final currentDisplayTurnedOn = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOn, true);

      // find pause button and press it
      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester.tester, pauseButton);

      // close journey
      final closeButton = find.byKey(JourneyPage.disconnectButtonKey);
      expect(closeButton, findsOneWidget);

      await tapElement(tester.tester, closeButton);

      // Get that the always-on display is turned off, because the journey is closed
      final currentDisplayTurnedOff = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOff, false);
    });

    patrolTest('test app bar is hiding while train is active', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      final date = Format.dateWithAbbreviatedDay(DateTime.now(), deviceLocale());
      final appbarText = '${l10n.p_train_journey_appbar_text} - $date';

      expect(find.text(appbarText).hitTestable(), findsNothing);

      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester.tester, pauseButton);

      expect(find.text(appbarText).hitTestable(), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('test check if switch theme is possible', (tester) async {
      await prepareAndStartApp(tester.tester);

      // Load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final context = tester.tester.element(header);

      final brightness = SBBBaseStyle.of(context).brightness;

      final searchedButtonLabel = brightness != Brightness.dark
          ? l10n.p_train_journey_header_button_dark_theme
          : l10n.p_train_journey_header_button_light_theme;

      final themeSwitchButton = find.descendant(
        of: header,
        matching: find.widgetWithText(SBBTertiaryButtonLarge, searchedButtonLabel),
      );
      expect(themeSwitchButton, findsOneWidget);
      await tester.tester.tap(themeSwitchButton);

      await tester.tester.pumpAndSettle(Duration(milliseconds: 300));

      expect(SBBBaseStyle.of(context).brightness != brightness, true);
    });

    patrolTest('test extended menu opening', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      await openExtendedMenu(tester.tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await dismissExtendedMenu(tester.tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('test extended maneuver mode', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      await openExtendedMenu(tester.tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await tapElement(tester.tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await openExtendedMenu(tester.tester);

      await tapElement(tester.tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('test maneuver mode notification switch button', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      await openExtendedMenu(tester.tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await tapElement(tester.tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await tapElement(tester.tester, find.byKey(ManeuverNotification.maneuverNotificationSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('test battery over 15% and not show icon', (tester) async {
      await prepareAndStartApp(tester.tester);

      // Set Battery to a mocked version
      final battery = DI.get<Battery>() as MockBattery;

      // Set current Battery-Level to 80 % so it is over 15%
      battery.currentBatteryLevel = 80;

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      expect(battery.currentBatteryLevel, 80);

      final batteryIcon = find.descendant(of: header, matching: find.byKey(BatteryStatus.batteryLevelLowIconKey));
      expect(batteryIcon, findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('test battery under 15% icon and modal are showing or opening', (tester) async {
      await prepareAndStartApp(tester.tester);

      // Set Battery to a mocked version
      final battery = DI.get<Battery>() as MockBattery;

      // Set current Battery-Level to 10% so it is under 15%
      battery.currentBatteryLevel = 10;

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      expect(battery.currentBatteryLevel, 10);

      final batteryIcon = find.descendant(of: header, matching: find.byKey(BatteryStatus.batteryLevelLowIconKey));
      expect(batteryIcon, findsOneWidget);

      await tester.tester.tap(batteryIcon);

      await tester.tester.pumpAndSettle();

      expect(find.text(l10n.w_modal_sheet_battery_status_battery_almost_empty), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('check if punctuality update sent is correct', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T9999');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await waitUntilExists(
        tester.tester,
        find.descendant(of: header, matching: find.byKey(DASChronograph.punctualityTextKey)),
      );
      await tester.tester.pumpAndSettle(Duration(seconds: 1));

      expect(find.descendant(of: header, matching: find.text('+00:30')), findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('chronograph punctuality display is hidden when no calculated speed', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T6');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.tester.pumpAndSettle();

      // does not find delay text
      expect(find.descendant(of: header, matching: find.byKey(DASChronograph.punctualityTextKey)), findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('check if the displayed current time is correct', (tester) async {
      await prepareAndStartApp(tester.tester);

      await loadTrainJourney(tester.tester, trainNumber: 'T6');

      await tester.tester.pumpAndSettle(const Duration(milliseconds: 200));

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final currentTimeText = tester.tester.widget<Text>(
        find.descendant(of: header, matching: find.byKey(DASChronograph.currentTimeTextKey)),
      );

      final displayedTime = currentTimeText.data;

      expect(displayedTime, isNotEmpty);

      // compare the range up to three seconds to allow some slack
      final now = tester.tester.binding.clock.now();
      final expectedTime = DateFormat('HH:mm:ss').format(now);

      final displayedDateTime = DateTime.parse('1970-01-01 $displayedTime');
      final expectedDateTime = DateTime.parse('1970-01-01 $expectedTime');

      final difference = displayedDateTime.difference(expectedDateTime).inSeconds.abs();
      expect(difference <= 3, isTrue);

      await disconnect(tester.tester);
    });

    patrolTest('test display of communication network in header', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T12');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      // check network type for Wankdorf
      final wankdorf = find.descendant(of: header, matching: find.text('Wankdorf'));
      expect(wankdorf, findsOneWidget);
      final wankdorfGsmRIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(wankdorfGsmRIcon, findsNothing);
      final wankdorfGsmPIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(wankdorfGsmPIcon, findsNothing);

      // check network type for Burgdorf
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Burgdorf')));
      final burgdorfGsmPIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(burgdorfGsmPIcon, findsOneWidget);

      // check network type for Olten (SIM displayed)
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Olten')));
      final oltenGsmPIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(oltenGsmPIcon, findsNothing);

      // check network type for Zürich
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Zürich')));
      final zuerichGsmRIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(zuerichGsmRIcon, findsOneWidget);

      await disconnect(tester.tester);
    });

    patrolTest('test display of radio contactList channels in header', (tester) async {
      await prepareAndStartApp(tester.tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester.tester, trainNumber: 'T12');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);
      // find the radioChannel and check if it is existent
      final radioChannel = find.descendant(of: header, matching: find.byType(RadioChannel));
      expect(radioChannel, findsOneWidget);

      // check empty radio contactList for Bern (nextStop: Wankdorf)
      final nextStopWankdorf = find.descendant(of: header, matching: find.text('Wankdorf'));
      expect(nextStopWankdorf, findsOneWidget);
      final mainContactBern = find.descendant(
        of: radioChannel,
        matching: find.byKey(RadioContactChannels.radioContactChannelsKey),
      );
      expect(mainContactBern, findsNothing);
      final bernIndicator = find.descendant(of: radioChannel, matching: find.byKey(DotIndicator.indicatorKey));
      expect(bernIndicator, findsNothing);
      final bernSim = find.descendant(of: radioChannel, matching: find.byKey(SimIdentifier.simKey));
      expect(bernSim, findsNothing);

      // check mainContacts for Wankdorf (nextStop: Burgdorf)
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Burgdorf')));
      final mainContactWankdorf = find.descendant(of: radioChannel, matching: find.text('1407'));
      expect(mainContactWankdorf, findsOneWidget);
      final wankdorfIndicator = find.descendant(of: radioChannel, matching: find.byKey(DotIndicator.indicatorKey));
      expect(wankdorfIndicator, findsNothing);
      final wankdorfSim = find.descendant(of: radioChannel, matching: find.byKey(SimIdentifier.simKey));
      expect(wankdorfSim, findsNothing);

      // check mainContacts for Burgdorf (nextStop: Olten)
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Olten')));
      final mainContactsBurgdorf = find.descendant(of: radioChannel, matching: find.text('1608 (1609)'));
      expect(mainContactsBurgdorf, findsOneWidget);
      final burgdorfIndicator = find.descendant(of: radioChannel, matching: find.byKey(DotIndicator.indicatorKey));
      expect(burgdorfIndicator, findsOneWidget);
      final burgdorfSim = find.descendant(of: radioChannel, matching: find.byKey(SimIdentifier.simKey));
      expect(burgdorfSim, findsOneWidget);

      // check mainContacts for Olten (nextStop: Zürich)
      await waitUntilExists(tester.tester, find.descendant(of: header, matching: find.text('Zürich')));
      final mainContactsOlten = find.descendant(of: radioChannel, matching: find.text('1102'));
      expect(mainContactsOlten, findsOneWidget);
      final oltenIndicator = find.descendant(of: radioChannel, matching: find.byKey(DotIndicator.indicatorKey));
      expect(oltenIndicator, findsOneWidget);
      final oltenSim = find.descendant(of: radioChannel, matching: find.byKey(SimIdentifier.simKey));
      expect(oltenSim, findsNothing);

      await disconnect(tester.tester);
    });

    // can be removed based on what option to change the brightness will be chosen
    patrolTest('double tap sets brightness to 0.0 if current is 1.0', (tester) async {
      await prepareAndStartApp(
        tester.tester,
        onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false,
      );

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester.tester);

      mockBrightnessManager.writeSettingsPermission = true;

      await loadTrainJourney(tester.tester, trainNumber: 'T6M');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final chronograph = find.byType(DASChronograph);
      expect(chronograph, findsOneWidget);

      await tester.tester.tap(chronograph);
      await tester.tester.pump(const Duration(milliseconds: 50));
      await tester.tester.tap(chronograph);
      await tester.tester.pumpAndSettle();

      expect(mockBrightnessManager.calledWith, contains(0.0));

      await disconnect(tester.tester);
    });

    // can be removed based on what option to change the brightness will be chosen
    patrolTest('horizontal drag right increases brightness', (tester) async {
      await prepareAndStartApp(
        tester.tester,
        onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false,
      );

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester.tester);

      mockBrightnessManager.writeSettingsPermission = true;
      mockBrightnessManager.currentBrightness = 0.5;

      await loadTrainJourney(tester.tester, trainNumber: 'T6');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.tester.drag(header, const Offset(100, 0));
      await tester.tester.pumpAndSettle();

      expect(
        mockBrightnessManager.calledWith.any((val) => val > 0.5),
        true,
      );

      await disconnect(tester.tester);
    });

    patrolTest('horizontal drag left decreases brightness', (tester) async {
      await prepareAndStartApp(
        tester.tester,
        onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false,
      );

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester.tester);

      mockBrightnessManager.writeSettingsPermission = true;
      mockBrightnessManager.currentBrightness = 0.5;

      await loadTrainJourney(tester.tester, trainNumber: 'T6');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.tester.drag(header, const Offset(-100, 0));
      await tester.tester.pumpAndSettle();

      expect(
        mockBrightnessManager.calledWith.any((val) => val < 0.5),
        true,
      );

      await disconnect(tester.tester);
    });
  });
}

Future<void> findAndDismissBrightnessModalSheet(WidgetTester tester) async {
  // find brightness modal sheet
  final brightnessModalSheet = find.byType(SBBModalSheet);
  expect(brightnessModalSheet, findsOneWidget);

  //find close button
  final closeButton = find.descendant(of: brightnessModalSheet, matching: find.byType(SBBIconButtonSmall));
  expect(closeButton, findsOneWidget);

  //tap close button
  await tester.tap(closeButton);
  await tester.pumpAndSettle();
}
