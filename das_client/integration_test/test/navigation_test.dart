import 'package:das_client/pages/fahrt/fahrt_page.dart';
import 'package:das_client/pages/links/links_page.dart';
import 'package:das_client/pages/profile/profile_page.dart';
import 'package:das_client/pages/settings/settings_page.dart';
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
      var scaffold = find.byWidgetPredicate((widget) => widget is Scaffold).first;
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

    testWidgets('test navigate to fahrbild', (tester) async {
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
      expect(find.byType(FahrtPage), findsOneWidget);
    });
  });
}