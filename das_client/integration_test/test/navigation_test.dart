import 'package:das_client/pages/fahrt/fahrt_page.dart';
import 'package:das_client/pages/links/links_page.dart';
import 'package:das_client/pages/profile/profile_page.dart';
import 'package:das_client/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
      expect(find.text('Fahrtinfo'), findsNothing);
      expect(find.text('Links'), findsNothing);
      expect(find.text('Einstellungen'), findsNothing);
      expect(find.text('Profil'), findsNothing);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text('Fahrtinfo'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('test navigate to links', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text('Links'), findsOneWidget);

      await tapElement(tester, find.text('Links'));

      // Check drawer is closed
      expect(find.text('Einstellungen'), findsNothing);
      expect(find.text('Profil'), findsNothing);

      // Check on LinksPage
      expect(find.byType(LinksPage), findsOneWidget);
    });

    testWidgets('test navigate to settings', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text('Einstellungen'), findsOneWidget);

      await tapElement(tester, find.text('Einstellungen'));

      // Check drawer is closed
      expect(find.text('Link'), findsNothing);
      expect(find.text('Profil'), findsNothing);

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
      expect(find.text('Profil'), findsOneWidget);

      await tapElement(tester, find.text('Profil'));

      // Check drawer is closed
      expect(find.text('Link'), findsNothing);
      expect(find.text('Einstellungen'), findsNothing);

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('test navigate to fahrbild', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text('Profil'), findsOneWidget);

      await tapElement(tester, find.text('Profil'));

      // Check drawer is closed
      expect(find.text('Link'), findsNothing);
      expect(find.text('Einstellungen'), findsNothing);

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);

      // check if navigation elements are present
      expect(find.text('Fahrtinfo'), findsOneWidget);

      await tapElement(tester, find.text('Fahrtinfo'));

      // Check on FahrtPage
      expect(find.byType(FahrtPage), findsOneWidget);
    });
  });
}

