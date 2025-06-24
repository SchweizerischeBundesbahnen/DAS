import 'dart:io';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';

Locale deviceLocale() {
  if (Platform.localeName.contains('_')) {
    final localeWithCountry = Platform.localeName.split('_');
    return Locale(localeWithCountry[0], localeWithCountry[1]);
  }
  return Locale(Platform.localeName);
}

Future<AppLocalizations> deviceLocalizations() async {
  return AppLocalizations.delegate.load(deviceLocale());
}

Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
  scaffoldState.openDrawer();

  // wait for drawer to open
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}

Future<void> tapElement(WidgetTester tester, FinderBase<Element> element, {bool warnIfMissed = true}) async {
  await tester.tap(element, warnIfMissed: warnIfMissed);
  await tester.pumpAndSettle();
}

Future<void> enterText(WidgetTester tester, FinderBase<Element> element, String text) async {
  await tester.enterText(element, text);
  await tester.pumpAndSettle();
}

Finder findTextFieldByLabel(String label) {
  final sbbTextField = find.byWidgetPredicate((widget) => widget is SBBTextField && widget.labelText == label);
  return find.descendant(of: sbbTextField, matching: find.byType(TextField));
}

Finder findDASTableRowByText(String text) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey)),
  );
}

/// Verifies, that SBB is selected and loads train journey with [trainNumber]
Future<void> loadTrainJourney(WidgetTester tester, {required String trainNumber}) async {
  // verify we have ru SBB selected.
  expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

  final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
  expect(trainNumberText, findsOneWidget);

  await enterText(tester, trainNumberText, trainNumber);

  // load train journey
  final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
  await tester.tap(primaryButton);

  // wait for train journey to load
  await tester.pumpAndSettle();
}

Future<void> disconnect(WidgetTester tester) async {
  DI.get<SferaRemoteRepo>().disconnect();
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> openExtendedMenu(WidgetTester tester) async {
  final menuButton = find.byKey(ExtendedMenu.menuButtonKey);
  await tapElement(tester, menuButton);
  await Future.delayed(const Duration(milliseconds: 250));
}

Future<void> openReducedJourneyMenu(WidgetTester tester) async {
  await openExtendedMenu(tester);
  await tapElement(tester, find.text(l10n.w_extended_menu_journey_overview_action));
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> dismissExtendedMenu(WidgetTester tester) async {
  final closeButton = find.byKey(ExtendedMenu.menuButtonCloseKey);
  await tapElement(tester, closeButton.first);
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> selectBreakSeries(WidgetTester tester, {required String breakSeries}) async {
  // Open break series bottom sheet
  await tapElement(tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

  // Check if the bottom sheet is opened
  expect(find.text(l10n.p_train_journey_break_series), findsOneWidget);
  await tapElement(tester, find.text(breakSeries));

  // confirm button
  await tapElement(tester, find.text(l10n.c_button_confirm));
}

Future<void> pauseAutomaticAdvancement(WidgetTester tester) async {
  final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
  expect(pauseButton, findsOneWidget);
  await tapElement(tester, pauseButton);
}

Future<void> waitUntilExists(WidgetTester tester, FinderBase<Element> element, {int maxWaitSeconds = 15}) async {
  int counter = 0;
  while (true) {
    await tester.pump(const Duration(milliseconds: 100));

    element.reset();
    if (element.evaluate().isNotEmpty) {
      break;
    }

    // cancel after maxWaitSeconds seconds
    if (counter++ > maxWaitSeconds * 10) {
      // makes the test fail
      expect(element, findsAny);
      break;
    }
  }

  // wait till all animations are finished
  await tester.pumpAndSettle();
}

Future<void> waitUntilNotExists(WidgetTester tester, FinderBase<Element> element, {int maxWaitSeconds = 10}) async {
  int counter = 0;
  while (true) {
    await tester.pump(const Duration(milliseconds: 100));

    element.reset();
    if (element.evaluate().isEmpty) {
      break;
    }

    // cancel after maxWaitSeconds seconds
    if (counter++ > maxWaitSeconds * 10) {
      // makes the test fail
      expect(element, findsNothing);
      break;
    }
  }

  // wait till all animations are finished
  await tester.pumpAndSettle();
}

// integration tests fail if an overflow error occurs
void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  final exception = details.exception;
  if (exception is FlutterError && exception.isPixelOverflowError) {
    debugPrint('Ignored Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}

extension _FlutterErrorExtension on FlutterError {
  bool get isPixelOverflowError => diagnostics.any((e) => e.value.toString().startsWith('A RenderFlex overflowed by'));
}
