import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_channel.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_contact.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:das_client/app/widgets/indicator_wrapper.dart';
import 'package:das_client/brightness/brightness_manager.dart';
import 'package:das_client/di.dart';
import 'package:das_client/util/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app_test.dart';
import '../mocks/battery_mock.dart';
import '../mocks/brightness_mock.dart';
import '../util/test_utils.dart';

Future<void> main() async {
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

  group('train journey header test', () {
    testWidgets('test always-on display is turned on when journey is loaded', (tester) async {
      await prepareAndStartApp(tester);

      // Get that the always-on display is turned off, because journey is not started yet
      final currentDisplayTurnedOff = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOff, false);

      await loadTrainJourney(tester, trainNumber: 'T4');

      // Get that the always-on display is turned on, because the journey is started
      final currentDisplayTurnedOn = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOn, true);
    });

    testWidgets('test always-on display is turned off when journey is closed', (tester) async {
      await prepareAndStartApp(tester);

      await loadTrainJourney(tester, trainNumber: 'T4');

      // Get that the always-on display is turned on, because the journey is started
      final currentDisplayTurnedOn = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOn, true);

      // find pause button and press it
      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // close journey
      final disconnectKey = Key('disconnectButton');
      final closeButton = find.byKey(disconnectKey);
      expect(closeButton, findsOneWidget);

      await tapElement(tester, closeButton);

      // Get that the always-on display is turned off, because the journey is closed
      final currentDisplayTurnedOff = await WakelockPlus.enabled;
      expect(currentDisplayTurnedOff, false);
    });

    testWidgets('test app bar is hiding while train is active', (tester) async {
      final testLocale = const Locale('de', 'CH');

      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      final date = Format.dateWithAbbreviatedDay(DateTime.now(), testLocale);
      final appbarText = '${l10n.p_train_journey_appbar_text} - $date';

      expect(find.text(appbarText).hitTestable(), findsNothing);

      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      expect(find.text(appbarText).hitTestable(), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test check if switch theme is possible', (tester) async {
      await prepareAndStartApp(tester);

      // Load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final context = tester.element(header);

      final brightness = SBBBaseStyle.of(context).brightness;

      if (brightness != Brightness.dark) {
        final nightMode = find.descendant(
          of: header,
          matching: find.widgetWithText(SBBTertiaryButtonLarge, 'Nachtmodus'),
        );
        expect(nightMode, findsOneWidget);

        await tester.tap(nightMode);
        await tester.pumpAndSettle();
      } else {
        final dayMode = find.descendant(
          of: header,
          matching: find.widgetWithText(SBBTertiaryButtonLarge, 'Tagmodus'),
        );
        expect(dayMode, findsOneWidget);

        await tester.tap(dayMode);
        await tester.pumpAndSettle();
      }

      expect(SBBBaseStyle.of(context).brightness != brightness, true);
    });

    testWidgets('test extended menu opening', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      await openExtendedMenu(tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await dismissExtendedMenu(tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test extended maneuver mode', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      await openExtendedMenu(tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await tapElement(tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await openExtendedMenu(tester);

      await tapElement(tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test maneuver mode notification switch button', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      await openExtendedMenu(tester);

      expect(find.byKey(ExtendedMenu.menuButtonCloseKey), findsAny);

      await tapElement(tester, find.byKey(ExtendedMenu.maneuverSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsOneWidget);

      await tapElement(tester, find.byKey(ManeuverNotification.maneuverNotificationSwitchKey));

      expect(find.text(l10n.w_maneuver_notification_text), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test battery over 15% and not show icon', (tester) async {
      await prepareAndStartApp(tester);

      // Set Battery to a mocked version
      final battery = DI.get<Battery>() as BatteryMock;

      // Set current Battery-Level to 80 % so it is over 15%
      battery.currentBatteryLevel = 80;

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      expect(battery.currentBatteryLevel, 80);

      final batteryIcon = find.descendant(of: header, matching: find.byKey(BatteryStatus.batteryLevelLowIconKey));
      expect(batteryIcon, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test battery under 15% icon and modal are showing or opening', (tester) async {
      await prepareAndStartApp(tester);

      // Set Battery to a mocked version
      final battery = DI.get<Battery>() as BatteryMock;

      // Set current Battery-Level to 10% so it is under 15%
      battery.currentBatteryLevel = 10;

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      expect(battery.currentBatteryLevel, 10);

      final batteryIcon = find.descendant(of: header, matching: find.byKey(BatteryStatus.batteryLevelLowIconKey));
      expect(batteryIcon, findsOneWidget);

      await tester.tap(batteryIcon);

      await tester.pumpAndSettle();

      expect(find.text(l10n.w_modal_sheet_battery_status_battery_almost_empty), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('check if punctuality update sent is correct', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      // Find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await waitUntilNotExists(tester, find.descendant(of: header, matching: find.text('+00:00')));

      expect(find.descendant(of: header, matching: find.text('+00:30')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('find base value when no punctuality update comes', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      // find the text in the header
      expect(find.descendant(of: header, matching: find.text('+00:00')), findsOneWidget);

      await tester.pumpAndSettle();

      await disconnect(tester);
    });

    testWidgets('check if the displayed current time is correct', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final DateTime currentTime = DateTime.now();
      final String currentHour = currentTime.hour <= 9 ? '0${currentTime.hour}' : (currentTime.hour).toString();
      final String currentMinutes =
          currentTime.minute <= 9 ? '0${currentTime.minute}' : (currentTime.minute).toString();
      final String currentSeconds =
          currentTime.second <= 9 ? '0${currentTime.second}' : (currentTime.second).toString();
      final String nextSecond =
          currentTime.second <= 9 ? '0${currentTime.second + 1}' : (currentTime.second + 1).toString();
      final String currentWholeTime = '$currentHour:$currentMinutes:$currentSeconds';
      final String nextSecondWholeTime = '$currentHour:$currentMinutes:$nextSecond';

      if (!find.descendant(of: header, matching: find.text(currentWholeTime)).evaluate().isNotEmpty) {
        expect(find.descendant(of: header, matching: find.text(nextSecondWholeTime)), findsOneWidget);
      } else {
        expect(find.descendant(of: header, matching: find.text(currentWholeTime)), findsOneWidget);
      }

      await tester.pumpAndSettle();

      await disconnect(tester);
    });

    testWidgets('test display of communication network in header', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T12');

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
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Burgdorf')));
      final burgdorfGsmPIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(burgdorfGsmPIcon, findsOneWidget);

      // check network type for Olten
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Olten')));
      final oltenGsmPIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(oltenGsmPIcon, findsOneWidget);

      // check network type for Zürich
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Zürich')));
      final zuerichGsmRIcon = find.descendant(of: header, matching: find.byKey(CommunicationNetworkIcon.gsmRKey));
      expect(zuerichGsmRIcon, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test display of radio contactList channels in header', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T12');

      // find the header and check if it is existent
      final header = find.byType(Header);
      expect(header, findsOneWidget);
      // find the radioChannel and check if it is existent
      final radioChannel = find.descendant(of: header, matching: find.byType(RadioChannel));
      expect(radioChannel, findsOneWidget);

      // check empty radio contactList for Wankdorf
      final wankdorf = find.descendant(of: header, matching: find.text('Wankdorf'));
      expect(wankdorf, findsOneWidget);
      final mainContactsWankdorf =
          find.descendant(of: radioChannel, matching: find.byKey(RadioContactChannels.radioContactChannelsKey));
      expect(mainContactsWankdorf, findsNothing);
      final wankdorfIndicator = find.descendant(of: radioChannel, matching: find.byKey(IndicatorWrapper.indicatorKey));
      expect(wankdorfIndicator, findsNothing);

      // check mainContacts for Burgdorf
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Burgdorf')));
      final mainContactsBurgdorf = find.descendant(of: radioChannel, matching: find.text('1407'));
      expect(mainContactsBurgdorf, findsOneWidget);
      final burgdorfIndicator = find.descendant(of: radioChannel, matching: find.byKey(IndicatorWrapper.indicatorKey));
      expect(burgdorfIndicator, findsNothing);

      // check mainContacts for Olten
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Olten')));
      final mainContactsOlten = find.descendant(of: radioChannel, matching: find.text('1608 (1609)'));
      expect(mainContactsOlten, findsOneWidget);
      final oltenIndicator = find.descendant(of: radioChannel, matching: find.byKey(IndicatorWrapper.indicatorKey));
      expect(oltenIndicator, findsOneWidget);

      // check mainContacts for Zürich
      await waitUntilExists(tester, find.descendant(of: header, matching: find.text('Zürich')));
      final mainContactsZurich = find.descendant(of: radioChannel, matching: find.text('1102'));
      expect(mainContactsZurich, findsOneWidget);
      final zuerichIndicator = find.descendant(of: radioChannel, matching: find.byKey(IndicatorWrapper.indicatorKey));
      expect(zuerichIndicator, findsOneWidget);

      await disconnect(tester);
    });

    // can be removed based on what option to change the brightness will be chosen
    testWidgets('double tap sets brightness to 0.0 if current is 1.0', (tester) async {
      await prepareAndStartApp(tester,
          onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false);

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester);

      mockBrightnessManager.writeSettingsPermission = true;

      await loadTrainJourney(tester, trainNumber: 'T6M');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      final timeContainer = find.byType(TimeContainer);
      expect(timeContainer, findsOneWidget);

      await tester.tap(timeContainer);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(timeContainer);
      await tester.pumpAndSettle();

      expect(mockBrightnessManager.calledWith, contains(0.0));

      await disconnect(tester);
    });

    // can be removed based on what option to change the brightness will be chosen
    testWidgets('long press dims brightness from 1.0 to 0.0', (tester) async {
      await prepareAndStartApp(tester,
          onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false);

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester);

      await loadTrainJourney(tester, trainNumber: 'T6');

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester);

      final timeContainer = find.byType(TimeContainer);
      expect(timeContainer, findsOneWidget);

      await tester.longPress(timeContainer);
      await tester.pump(const Duration(seconds: 2));

      expect(mockBrightnessManager.calledWith.any((val) => val < 1.0), true);

      await disconnect(tester);
    });

    // can be removed based on what option to change the brightness will be chosen
    testWidgets('horizontal drag right increases brightness', (tester) async {
      await prepareAndStartApp(tester,
          onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false);

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester);

      mockBrightnessManager.writeSettingsPermission = true;
      mockBrightnessManager.currentBrightness = 0.5;

      await loadTrainJourney(tester, trainNumber: 'T6');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.drag(header, const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(
        mockBrightnessManager.calledWith.any((val) => val > 0.5),
        true,
      );

      await disconnect(tester);
    });

    testWidgets('horizontal drag left decreases brightness', (tester) async {
      await prepareAndStartApp(tester,
          onBeforeRun: () => (DI.get<BrightnessManager>() as MockBrightnessManager).writeSettingsPermission = false);

      final mockBrightnessManager = DI.get<BrightnessManager>() as MockBrightnessManager;

      // automatically opening modal sheet if write permissions not given (in tests hasWritePermissions is always false)
      await findAndDismissBrightnessModalSheet(tester);

      mockBrightnessManager.writeSettingsPermission = true;
      mockBrightnessManager.currentBrightness = 0.5;

      await loadTrainJourney(tester, trainNumber: 'T6');

      final header = find.byType(Header);
      expect(header, findsOneWidget);

      await tester.drag(header, const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(
        mockBrightnessManager.calledWith.any((val) => val < 0.5),
        true,
      );

      await disconnect(tester);
    });
  });
}
