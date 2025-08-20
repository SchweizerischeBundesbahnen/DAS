import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/links/links_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('navigation drawer tests', () {
    testWidgets('should show navigation drawer', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // check that there is a drawer
      final scaffold = find.byWidgetPredicate((widget) => widget is Scaffold).first;
      expect(tester.widget<Scaffold>(scaffold).drawer, isNotNull);

      // check that drawer is not shown
      expect(find.text(l10n.w_navigation_drawer_fahrtinfo_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsNothing);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_fahrtinfo_title), findsOneWidget);
      expect(find.text(l10n.w_navigation_drawer_links_title), findsOneWidget);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsOneWidget);
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsOneWidget);
    });

    testWidgets('test navigate to links', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_links_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_links_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsNothing);

      // Check on LinksPage
      expect(find.byType(LinksPage), findsOneWidget);
    });

    testWidgets('test navigate to settings', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsNothing);

      // Check on SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('test navigate to profile', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('test navigate to train journey', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_profile_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_fahrtinfo_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // Check on FahrtPage
      expect(find.byType(JourneySelectionPage), findsOneWidget);
    });

    testWidgets('test if train journey stays loaded after navigation', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

      // check first train station
      expect(findDASTableRowByText('Zürich HB'), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // check first train station is still visible
      expect(findDASTableRowByText('Zürich HB'), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test journey settings are not reset when navigating ', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T5');
      await toggleAutomaticAdvancement(tester);

      final selectedBreakSeries = 'D30';
      await selectBreakSeries(tester, breakSeries: selectedBreakSeries);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // check the selected train series is still selected
      expect(find.text(selectedBreakSeries), findsOneWidget);

      await disconnect(tester);
    });
  });
}
