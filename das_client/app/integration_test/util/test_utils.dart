import 'dart:io';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_page.dart';
import 'package:app/pages/journey/journey_table/widgets/header/extended_menu.dart';
import 'package:app/pages/journey/journey_table/widgets/header/next_stop.dart';
import 'package:app/pages/journey/journey_table/widgets/header/start_pause_button.dart';
import 'package:app/pages/journey/journey_table/widgets/journey_table.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/scrollable_align.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';

Locale appLocale() => Locale(l10n.localeName);

Future<AppLocalizations> deviceLocalizations() async {
  return AppLocalizations.delegate.load(_deviceLocale());
}

Locale _deviceLocale() {
  if (Platform.localeName.contains('_')) {
    final localeWithCountry = Platform.localeName.split('_');
    return Locale(localeWithCountry[0], localeWithCountry[1]);
  }
  return Locale(Platform.localeName);
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

Finder findTextFieldByHint(String hint) {
  final sbbTextField = find.byWidgetPredicate((widget) => widget is SBBTextField && widget.hintText == hint);
  return find.descendant(of: sbbTextField, matching: find.byType(TextField));
}

Finder findDASTableRowByText(String text) {
  return find.descendant(
    of: find.byKey(DASTable.tableKey),
    matching: find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey)),
  );
}

Finder findDASTableColumnByText(String text) {
  return find.ancestor(of: find.text(text), matching: find.byKey(DASTable.columnHeaderKey));
}

Finder findColoredRowCells({required FinderBase<Element> of, required Color color}) {
  return find.descendant(
    of: of,
    matching: find.byWidgetPredicate(
      (it) => it is Container && it.decoration is BoxDecoration && (it.decoration as BoxDecoration).color == color,
    ),
  );
}

/// Verifies, that SBB is selected and loads train journey with [trainNumber]
Future<void> loadJourney(WidgetTester tester, {required String trainNumber}) async {
  // verify we have ru SBB selected.
  expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

  final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
  expect(trainNumberText, findsOneWidget);

  await enterText(tester, trainNumberText, trainNumber);

  // load train journey
  final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
  await tester.tap(primaryButton);

  // wait for train journey to load
  await waitUntilExists(tester, find.byKey(JourneyTable.loadedJourneyTableKey));
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
  await tapElement(tester, find.byKey(NextStop.tappableAreaKey));
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> openBreakSlipPage(WidgetTester tester) async {
  await openExtendedMenu(tester);
  await tapElement(tester, find.text(l10n.w_extended_menu_breaking_slip_action));
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> closeBreakSlipPage(WidgetTester tester) async {
  await tapElement(tester, find.byKey(BreakLoadSlipPage.dismissButtonKey));
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> dismissExtendedMenu(WidgetTester tester) async {
  final closeButton = find.byKey(ExtendedMenu.menuButtonCloseKey);
  await tapElement(tester, closeButton.first);
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> selectBreakSeries(WidgetTester tester, {required String breakSeries}) async {
  // Open break series bottom sheet
  await tapElement(tester, find.byKey(JourneyTable.breakingSeriesHeaderKey));

  // Check if the bottom sheet is opened
  expect(find.text(l10n.p_journey_break_series), findsOneWidget);
  await tapElement(tester, find.text(breakSeries));
}

Future<void> stopAutomaticAdvancement(WidgetTester tester) async {
  final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
  expect(pauseButton, findsOneWidget);
  await tapElement(tester, pauseButton);
}

Future<void> startAutomaticAdvancement(WidgetTester tester) async {
  final startButton = find.byKey(StartPauseButton.startButtonKey);
  expect(startButton, findsOneWidget);
  await tapElement(tester, startButton);
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

Future<void> dragUntilTextInStickyHeader(WidgetTester tester, String textToSearch) async {
  final scrollableFinder = find.byType(AnimatedList);
  final stickyHeader = find.byKey(StickyHeader.headerKey);
  await tester.dragUntilVisible(
    find.descendant(of: stickyHeader, matching: find.text(textToSearch)),
    scrollableFinder,
    const Offset(0, -50),
    maxIteration: 100,
  );
  await tester.pumpAndSettle(ScrollableAlign.alignScrollDuration);
}
