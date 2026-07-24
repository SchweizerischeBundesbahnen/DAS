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
    testWidgets('navigation_whenDrawerOpened_thenShowsNavigationItems', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('navigation_whenLinksSelected_thenShowsLinksPage', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('navigation_whenSettingsSelected_thenShowsSettingsPage', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('navigation_whenProfileSelected_thenShowsProfilePage', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('navigation_whenTrainJourneySelected_thenShowsFahrtPage', (tester) async {
      await IntegrationTestApp.start(tester);

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

    testWidgets('navigation_whenNavigatingBackToJourney_thenJourneyStaysLoaded', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T6');

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

    testWidgets('navigation_whenNavigatingBack_thenJourneySettingsNotReset', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T5M');

      final selectedBrakeSeries = 'D30';
      await selectBrakeSeries(tester, brakeSeries: selectedBrakeSeries);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // check the selected train series is still selected
      expect(find.text(selectedBrakeSeries), findsOneWidget);

      await disconnect(tester);
    });
  });
}
