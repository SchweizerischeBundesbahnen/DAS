import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../app_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
}
