import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/links/links_page.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:app/pages/support/support_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  group('navigation drawer tests', () {
    testWidgets('navigation_whenDrawerOpened_thenShowsAllNavigationItems|4zq12yxOhYBVFfmmbRMu|tests:80', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      // check that there is a drawer
      final scaffold = find.byWidgetPredicate((widget) => widget is Scaffold).first;
      expect(tester.widget<Scaffold>(scaffold).drawer, isNotNull);

      final drawerTitles = [
        l10n.w_navigation_drawer_links_title,
        l10n.w_navigation_drawer_settings_title,
        l10n.w_navigation_drawer_fahrordnung_title,
        l10n.w_navigation_drawer_support_title,
      ];

      // check that drawer is not shown
      for (final it in drawerTitles) {
        expect(find.text(it), findsNothing);
      }

      await openDrawer(tester);

      // check if navigation elements are present
      for (final it in drawerTitles) {
        expect(find.text(it), findsOneWidget);
      }
    });

    testWidgets('navigation_whenLinksSelected_thenShowsLinksPage|6ud9ZVIyRAaLfwadmi7b|tests:80', (tester) async {
      await IntegrationTestApp.start(tester);

      await openDrawer(tester);

      // check if navigation element is present
      expect(find.text(l10n.w_navigation_drawer_links_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_links_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);

      // Check on LinksPage
      expect(find.byType(LinksPage), findsOneWidget);
    });

    testWidgets('navigation_whenSettingsSelected_thenShowsSettingsPage|NSe6ERbY0uoKIFbulzBA|tests:80', (tester) async {
      await IntegrationTestApp.start(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_support_title), findsNothing);

      // Check on SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigation_whenSupportSelected_thenShowsSupportPage|uwGtLIS6brDbdk4shRWJ|tests:80', (tester) async {
      await IntegrationTestApp.start(tester);

      await openDrawer(tester);

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_support_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_support_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);

      // Check on SupportPage
      expect(find.byType(SupportPage), findsOneWidget);
    });

    testWidgets('navigation_whenJourneySelectionPageSelected_thenShowsSelectionPage|F5AHhw7WFEXFVWdrzZH6|tests:80', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

      // Check drawer is closed
      expect(find.text(l10n.w_navigation_drawer_links_title), findsNothing);
      expect(find.text(l10n.w_navigation_drawer_settings_title), findsNothing);

      // Check on SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text(l10n.w_navigation_drawer_fahrordnung_title), findsOneWidget);

      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrordnung_title));

      // Check on JourneySelectionPage
      expect(find.byType(JourneySelectionPage), findsOneWidget);
    });

    testWidgets('navigation_whenNavigatingBackToJourney_thenJourneyStaysLoaded|TVSAOe6GbJ5bWoqPD2v1|tests:80,1557', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T6');

      // check first train station
      expect(findDASTableRowByText('Zürich HB'), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

      // Check on SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrordnung_title));

      // check first train station is still visible
      expect(findDASTableRowByText('Zürich HB'), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('navigation_whenNavigatingBack_thenJourneySettingsNotReset|RijOj3T18mvGVZNMrmTq|tests:80,583,811', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T5M');

      final selectedBrakeSeries = 'D30';
      await selectBrakeSeries(tester, brakeSeries: selectedBrakeSeries);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_settings_title));

      // Check on SettingsPage
      expect(find.byType(SettingsPage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrordnung_title));

      // check the selected train series is still selected
      expect(find.text(selectedBrakeSeries), findsOneWidget);

      await disconnect(tester);
    });
  });
}
