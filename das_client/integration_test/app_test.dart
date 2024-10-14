import 'package:das_client/flavor.dart';
import 'package:das_client/main.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'di.dart';
import 'test/fahrbild_test.dart' as FahrbildTests;
import 'test/navigation_test.dart' as NavigationTests;

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());

  group('home screen test', () {
    testWidgets('load fahrbild company=1088, train=9232', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have trainnumber with 9232.
      expect(find.text('9232'), findsOneWidget);

      // Verify we have company with 1088.
      expect(find.text('1088'), findsOneWidget);

      // check that the primary button is enabled
      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      // press load Fahrordnung button
      await tester.tap(primaryButton);

      // wait for fahrbild to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if station is present
      expect(find.text('MEER-GRENS'), findsOneWidget);
    });
  });

  group('navigation drawer tests', () {
    testWidgets('should show navigation drawer', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // check that there is a drawer
      var scaffold = find.byWidgetPredicate((widget) => widget is Scaffold).first;
      expect(tester.widget<Scaffold>(scaffold).drawer, isNotNull);

      // check that drawer is not shown
      expect(find.text('Fahrtinfo'), findsNothing);
      expect(find.text('Links'), findsNothing);
      expect(find.text('Einstellungen'), findsNothing);
      expect(find.text('Profil'), findsNothing);

      // open drawer
      final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
      scaffoldState.openDrawer();

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text('Fahrtinfo'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('test navigate to links', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // open drawer
      final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
      scaffoldState.openDrawer();

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text('Links'), findsOneWidget);

      var gestureDetector = find.ancestor(of: find.text('Links'), matching: find.byType(GestureDetector)).first;
      await tester.tap(gestureDetector);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check drawer is closed
      expect(find.text('Einstellungen'), findsNothing);
      expect(find.text('Profil'), findsNothing);

      expect(find.text('Links'), findsOneWidget);
    });

    testWidgets('test navigate to settings', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // open drawer
      final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
      scaffoldState.openDrawer();

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text('Einstellungen'), findsOneWidget);

      var gestureDetector = find.ancestor(of: find.text('Einstellungen'), matching: find.byType(GestureDetector)).first;
      await tester.tap(gestureDetector);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check drawer is closed
      expect(find.text('Link'), findsNothing);
      expect(find.text('Profil'), findsNothing);

      expect(find.text('Einstellungen'), findsOneWidget);
    });

    testWidgets('test navigate to profile', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // open drawer
      final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
      scaffoldState.openDrawer();

      // wait for drawer to open
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if navigation elements are present
      expect(find.text('Profil'), findsOneWidget);

      var gestureDetector = find.ancestor(of: find.text('Profil'), matching: find.byType(GestureDetector)).first;
      await tester.tap(gestureDetector);

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Check drawer is closed
      expect(find.text('Link'), findsNothing);
      expect(find.text('Einstellungen'), findsNothing);

      expect(find.text('Profil'), findsOneWidget);
    });
  });

  //FahrbildTests.main();
  //NavigationTests.main();
}

Future<void> prepareAndStartApp(WidgetTester tester) async {
  await IntegrationTestDI.init(Flavor.dev);
  runDasApp();
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
