import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/extended_menu.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';

Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
  scaffoldState.openDrawer();

  // wait for drawer to open
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}

Future<void> tapElement(WidgetTester tester, FinderBase<Element> element) async {
  await tester.tap(element);
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
      matching: find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey)));
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
  DI.get<TrainJourneyCubit>().reset();
  await Future.delayed(const Duration(milliseconds: 50));
}

Future<void> openExtendedMenu(WidgetTester tester) async {
  final menuButton = find.byKey(ExtendedMenu.menuButtonKey);
  await tapElement(tester, menuButton);
  await Future.delayed(const Duration(milliseconds: 250));
}

Future<void> dismissExtendedMenu(WidgetTester tester) async {
  final closeButton = find.byKey(ExtendedMenu.menuButtonCloseKey);
  await tapElement(tester, closeButton.first);
  await Future.delayed(const Duration(milliseconds: 100));
}

Future<void> waitUntilExists(WidgetTester tester, FinderBase<Element> element, {int maxWaitSeconds = 5}) async {
  int counter = 0;
  while (true) {
    await tester.pumpAndSettle();

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

    await Future.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> waitUntilNotExists(WidgetTester tester, FinderBase<Element> element, {int maxWaitSeconds = 5}) async {
  int counter = 0;
  while (true) {
    await tester.pumpAndSettle();

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

    await Future.delayed(const Duration(milliseconds: 100));
  }
}
