import 'package:app/di/di.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/model/tour_system.dart';
import 'package:app/provider/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../mocks/mock_launcher.dart';
import '../mocks/mock_user_settings.dart';
import '../util/test_utils.dart';

void main() {
  group('tour system link test', () {
    testWidgets('test tour system button buttons are not displayed when tour system is not configured', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T39M');

      // find pause button and press it
      final pauseButton = find.text(l10n.p_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);
      await tapElement(tester, pauseButton);

      expect(find.text(l10n.p_journey_overview_tour_button_text), findsNothing);

      await openExtendedMenu(tester);
      expect(find.text(l10n.w_extended_menu_tour_action), findsNothing);
      await dismissExtendedMenu(tester);

      await openDrawer(tester);
      expect(find.text(l10n.w_navigation_drawer_tour_system_title), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test tour system button buttons are displayed when tour system is configured', (tester) async {
      await prepareAndStartApp(tester);

      final userSettings = DI.get<UserSettings>() as MockUserSettings;
      userSettings.set(.tourSystem, TourSystem.tip.name);

      await loadJourney(tester, trainNumber: 'T39M');

      // find pause button and press it
      final pauseButton = find.text(l10n.p_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);
      await tapElement(tester, pauseButton);

      expect(find.text(l10n.p_journey_overview_tour_button_text), findsOne);
      await tapElement(tester, find.text(l10n.p_journey_overview_tour_button_text));

      await openExtendedMenu(tester);
      expect(find.text(l10n.w_extended_menu_tour_action), findsOne);
      await tapElement(tester, find.text(l10n.w_extended_menu_tour_action));
      await dismissExtendedMenu(tester);

      await openDrawer(tester);
      expect(find.text(l10n.w_navigation_drawer_tour_system_title), findsOne);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_tour_system_title));

      final launcher = DI.get<Launcher>() as MockLauncher;
      expect(launcher.launchedUrls, hasLength(3));
      expect(launcher.launchedUrls[0], TourSystem.tip.url);

      await disconnect(tester);
    });

    testWidgets('test tour system button displayed according to current position', (tester) async {
      await prepareAndStartApp(tester);

      final userSettings = DI.get<UserSettings>() as MockUserSettings;
      userSettings.set(.tourSystem, TourSystem.tip.name);

      await loadJourney(tester, trainNumber: 'T39');
      expect(find.text(l10n.p_journey_overview_tour_button_text), findsOne);

      await waitUntilNotExists(tester, find.text(l10n.p_journey_overview_tour_button_text));
      await waitUntilExists(tester, find.text(l10n.p_journey_overview_tour_button_text));

      await disconnect(tester);
    });
  });
}
