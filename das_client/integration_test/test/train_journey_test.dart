import 'dart:async';

import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('home screen test', () {
    testWidgets('load train journey company=1085, train=T9999', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have trainnumber with T9999.
      expect(find.text('T9999'), findsOneWidget);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // check that the primary button is enabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      // press load Fahrordnung button
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      // check if station is present
      expect(find.text('Haltestelle B'), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('show the correct next stop', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T6');

      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      //find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      //Find the text in the header
      expect(find.descendant(of: headerFinder, matching: find.text('Hardbrücke')), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  testWidgets('find base value when no punctuality update comes', (tester) async {
    // Load app widget.
    await prepareAndStartApp(tester);

    final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
    expect(trainNumberText, findsOneWidget);

    await enterText(tester, trainNumberText, 'T6');

    final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
    await tester.tap(primaryButton);

    // wait for train journey to load
    await tester.pumpAndSettle();

    //find the header and check if it is existent
    final headerFinder = find.byType(Header);
    expect(headerFinder, findsOneWidget);

    //Find the text in the header
    expect(find.descendant(of: headerFinder, matching: find.text('+00:00')), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('check if the displayed current time is correct', (tester) async {
    // Load app widget.
    await prepareAndStartApp(tester);

    //Select the correct train number
    final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
    expect(trainNumberText, findsOneWidget);

    await enterText(tester, trainNumberText, 'T6');

    //Log into the journey
    final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
    await tester.tap(primaryButton);

    // wait for train journey to load
    await tester.pumpAndSettle();

    //find the header and check if it is existent
    final headerFinder = find.byType(Header);
    expect(headerFinder, findsOneWidget);

    final DateTime currentTime = DateTime.now();
    final String currentHour = currentTime.hour <= 9 ? '0${currentTime.hour}' : (currentTime.hour).toString();
    final String currentMinutes = currentTime.hour <= 9 ? '0${currentTime.minute}' : (currentTime.minute).toString();
    final String currentSeconds = currentTime.hour <= 9 ? '0${currentTime.second}' : (currentTime.second).toString();
    final String nextSecond =
        currentTime.hour <= 9 ? '0${currentTime.second + 1}' : (currentTime.second + 1).toString();
    final String currentWholeTime = '$currentHour:$currentMinutes:$currentSeconds';
    final String nextSecondWholeTime = '$currentHour:$currentMinutes:$nextSecond';

    if (!find.descendant(of: headerFinder, matching: find.text(currentWholeTime)).evaluate().isNotEmpty) {
      expect(find.descendant(of: headerFinder, matching: find.text(nextSecondWholeTime)), findsOneWidget);
    } else {
      expect(find.descendant(of: headerFinder, matching: find.text(currentWholeTime)), findsOneWidget);
    }

    await tester.pumpAndSettle();
  });

  testWidgets('check if update sent is correct', (tester) async {
    // Load app widget.
    await prepareAndStartApp(tester);

    // Select the correct train number
    final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
    expect(trainNumberText, findsOneWidget);

    await enterText(tester, trainNumberText, 'T9999');

    // Log into the journey
    final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
    await tester.tap(primaryButton);

    // Wait for train journey to load
    await tester.pumpAndSettle();

    // Find the header and check if it is existent
    final headerFinder = find.byType(Header);
    expect(headerFinder, findsOneWidget);

    // Timer logic: increase timer every second, rerun the base every 100 ms and check if the UI changed
    int timer = 0;
    const maxTime = 10;
    int millisecondsCounter = 0;

    final completer = Completer<void>();

    expect(find.descendant(of: headerFinder, matching: find.text('+00:00')), findsOneWidget);

    while (!completer.isCompleted) {
      await tester.pumpAndSettle();

      if (!find.descendant(of: headerFinder, matching: find.text('+00:00')).evaluate().isNotEmpty) {
        expect(find.descendant(of: headerFinder, matching: find.text('+00:30')), findsOneWidget);
        completer.complete();
        break;
      }

      millisecondsCounter += 100;
      if (millisecondsCounter % 1000 == 0) {
        timer++;
      }

      if (timer > maxTime) {
        completer
            .completeError(Exception('UI did not change from the base value to the updated value (+00:00 -> +00:30)'));
        break;
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    await completer.future;

    await tester.pumpAndSettle();
  });
}
