import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/battery_status.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:das_client/di.dart';
import 'package:das_client/util/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../mocks/battery_mock.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey header test', () {
    testWidgets('test app bar is hiding while train is active', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      final date = Format.dateWithAbbreviatedDay(DateTime.now());
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

    testWidgets('test extended meneuver mode', (tester) async {
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

    testWidgets('test battery under 15% and show icon', (tester) async {
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
  });
}
